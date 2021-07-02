// Copyright (c) 2019-2021 Blockchain Presence
// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.7.0 <0.8.0;

contract BCPRegistration {

//*************************************************Structs************************************************************

    /** 
    @dev stores all sender addresses
    @param _PIN is the SCAs main address
    @param _PUK is the senders main address
    @param _PUK2a first of the PUK2 triplet. Is held by the sender
    @param _PUK2b second of the PUK2 triplet. Is held by the first trusted party
    @param _PUK2c third of the PUK2 triplet. Is held by the second trusted party
    */
    struct Sender{
        address payable _PIN;
        address payable _PUK;
        address _PUK2a;
        address _PUK2b;
        address _PUK2c;
    }

    /**
    @dev stores the PUK2 triplet for comparison reasons in the ResetPINPUK function
    @param _claimant is the address that called the ResetPINPUK function
    @param _newSender is the nested Sender struct
    */
    struct ResetPUK{
        address payable _claimant;
        Sender _newSender;
    }

//*************************************************Arrays*************************************************************

    Sender[] private senders;

//*************************************************Mappings************************************************************

    /**
    @dev maps PIN and PUK to SenderID
    NOTE: ensures that 
        (i) different SenderIDs have different PINs, and 
        (ii) PINs are not used as PUKs
    */
    mapping(address => int64) public keyMap;

    /**
    @dev maps SenderID to ResetPUK
    NOTE: recalls existing claims to reset (if any)
    */
    mapping(int64 => ResetPUK) private resetIndex;

//*************************************************Events************************************************************

    /**
    @param SenderID uint that identifies a specific sender (is constant)
    @param PIN is the main address
    @param PUK is the address to change the PIN address
    @param PUK2a first of the PUK2 triplet. Is held by the sender
    @param PUK2b second of the PUK2 triplet. Is held by the first trusted party
    @param PUK2c third of the PUK2 triplet. Is held by the second trusted party
     */
    event newSender(
        int64 SenderID,
        address payable PIN,
        address payable PUK,
        address PUK2a,
        address PUK2b,
        address PUK2c
    );

    /**
    @dev provides information of changed PIN to the website
    @param SenderID uint that identifies a specific sender (is constant)
    @param newPIN alternative PIN for the deleted one
     */
    event PINChanged(
        int64 SenderID,
        address newPIN
    );

    /**
    @dev provides information of calls of the ResetPINPUK function in its first stage of the reset process
    @param SenderID uint that identifies a specific sender (is constant)
    @param PIN is the main address
     */
    event newClaim(
        int64 SenderID,
        address payable PIN,
        address payable PUK,
        address PUK2a,
        address PUK2b,
        address PUK2c
    );

    /**
    @param CustomerAddress is the address that called the fallback function
    @param MonetaryAmount is the msg.value that was provided within the call
     */
    event fallbackCall(
        address CustomerAddress,
        uint MonetaryAmount
    );
    
    /**
    @param SenderID uint that identifies a specific sender (is constant)
    @param PIN is the main address
    @param PUK is the address to change the PIN address
    @param PUK2a first of the PUK2 triplet. Is held by the sender
    @param PUK2b second of the PUK2 triplet. Is held by the first trusted party
    @param PUK2c third of the PUK2 triplet. Is held by the second trusted party
     */
    event resetPINPUK(
        int64 SenderID,
        address payable PIN,
        address payable PUK,
        address PUK2a,
        address PUK2b,
        address PUK2c
    );

    //++++++++++++++++++++++++++++++++++++++++++++++++++Start of the Account Management module++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
     The account management module consists of four functions:
    - NewSenderPro: Sets up a sender account using five EOAs (PIN, PUK, and PUK2 triplet)
    - NewSender: Sets up a sender account using two EOAs (PIN, PUK)
    - ChangePIN: Allows to change the PIN
    - ResetPINPUK: Allows to reset the sender account (keeping the SenderID)
    */

    /**
    @dev function register allows to set PIN, PUK and PUK2 triplet, thereby creating the SenderID
    @dev this function has to be called via the PUK address
    @param _PIN is the SCAs main address
    @param _PUK is the senders main address
    @param _PUK2a first of the PUK2 triplet. Is held by the sender
    @param _PUK2b second of the PUK2 triplet. Is held by the first trusted party
    @param _PUK2c third of the PUK2 triplet. Is held by the second trusted party
    */
    function NewSenderPro(
        address payable _PIN, 
        address payable _PUK, 
        address _PUK2a, 
        address _PUK2b, 
        address _PUK2c)
        public returns(int64)
        {
        require(msg.sender == _PUK, "Not authorized!");
        //checks that the PUK, PUK2a, PUK2b and PUK2c are different addresses
        require(
            _PIN != _PUK &&
            _PIN != _PUK2a &&
            _PIN != _PUK2b &&
            _PIN != _PUK2c, "PIN can't be PUK/PUK2a/PUK2b/PUK2c"
            );
        require(keyMap[_PIN] == 0x0 , "PIN already in use");
        require(keyMap[_PUK] == 0x0, "PUK already in use");
        //creates SenderID and stores the sender information
        //notice that the first element within the array has the ID 0 since arrays start to count from 0
        int64 SenderID = int64(senders.length); // senders.length also int64?
        senders.push(Sender(
            _PIN,
            _PUK,
            _PUK2a,
            _PUK2b,
            _PUK2c));
        //create dependency PIN / PUK -> SenderID
        keyMap[_PIN] = SenderID;
        keyMap[_PUK] = SenderID;
        emit newSender(SenderID, _PIN, _PUK, _PUK2a, _PUK2b, _PUK2c);
        return(SenderID);
    }

    /**
    @dev function registers new senders within a lower security level using the PUK address as PUK und PUK2 triplet
    @param _PIN is the SCAs main address
    @param _PUK is the senders main address
     */
    function NewSender(
        address payable _PIN, 
        address payable _PUK
    ) 
        external returns(int64)
    {
        int64 SenderID = NewSenderPro(
            _PIN, 
            _PUK, 
            _PUK, 
            _PUK, 
            _PUK); // Braucht es diese Funktion überhaupt? Ja, Fürs Testen momentan in Ordnung. 
        return(SenderID);
    }

    /**
    @dev to change the PIN address
    @dev has to be called by the PUK
    @param _newPIN alternative PIN for the deleted one
    */
    function ChangePIN(address payable _newPIN) external{
    
    // 1. Authentication
        int64 senderID = keyMap[msg.sender];
        Sender storage s = senders[uint (senderID)];
        require(msg.sender == s._PUK, "Not authorized!");
    
    // 2. Formal check of PIN
        require(
        s._PUK2a != _newPIN &&
        s._PUK2b != _newPIN &&
        s._PUK2c != _newPIN, "Can't use PUK2a/PUK2b/PUK2c as PIN"
        );
        //requires that the PIN is not already in use => implies that the newPIN is not equal to the PUK or belongs to another sender
        require(keyMap[_newPIN] == 0x0, "PIN already in use");
    
    // 3. Documentation
        keyMap[s._PIN] = 0x0;
        s._PIN = _newPIN;
        keyMap[_newPIN] = senderID;
        emit PINChanged(senderID, _newPIN);
    }

    //@dev returns false if claim, 1 if PINPUK changed
    
    //formal correctness of the ResetPINPUK function doesnt get checked enough thoroughly...
    function ResetPINPUK(
        int64 SenderID, 
        address payable _newPIN, 
        address payable _newPUK, 
        address _newPUK2a, 
        address _newPUK2b, 
        address _newPUK2c
    )
        external returns(bool) 
    {
        require (SenderID>=0, "Must be a SenderID >= 0!");
        Sender storage s = senders[uint(SenderID)];
        ResetPUK storage r = resetIndex[SenderID]; 
    
    // 1. Authentication
        require ((msg.sender == s._PUK2a) || (msg.sender == s._PUK2b) || (msg.sender == s._PUK2c),"sender must be either PUK2a, PUK2b or PUK2c");
    
    // 2. Check formal correctness
        require (_newPIN != _newPUK && _newPIN != _newPUK2a && _newPIN != _newPUK2b && _newPIN != _newPUK2c ,"new PIN cannot be equal to new PUK or one of the PUK2 triplet");
        
    // 3. Further Authentication
        require ( msg.sender != r._claimant, "to approve the claim you have to use another address of the PUK2a/PUK2b/PUK2c triplet!"); 
    
    // 4. Case distinction
        if (s._PUK == s._PUK2a && 
            s._PUK == s._PUK2b && 
            s._PUK == s._PUK2c) {
                keyMap[s._PIN] = 0x0;
                keyMap[s._PUK] = 0x0;
                s._PIN = _newPIN;
                s._PUK = _newPUK;
                keyMap[_newPIN] = SenderID;
                keyMap[_newPUK] = SenderID;
                s._PUK2a = _newPUK2a;
                s._PUK2b = _newPUK2b;
                s._PUK2c = _newPUK2c;
                emit resetPINPUK(SenderID, _newPIN, _newPUK, _newPUK2a, _newPUK2b, _newPUK2c);
                return true;
            } else if (r._claimant == address(0)){
            r._claimant = msg.sender;
            r._newSender._PIN = _newPIN;
            r._newSender._PUK = _newPUK;
            r._newSender._PUK2a = _newPUK2a;
            r._newSender._PUK2b = _newPUK2b;
            r._newSender._PUK2c = _newPUK2c;
            emit newClaim(SenderID, _newPIN, _newPUK, _newPUK2a, _newPUK2b, _newPUK2c);
            return false;
        } else if (_newPIN == r._newSender._PIN && 
            _newPUK == r._newSender._PUK && 
            _newPUK2a == r._newSender._PUK2a && 
            _newPUK2b == r._newSender._PUK2b && 
            _newPUK2c ==r._newSender._PUK2c){
            keyMap[s._PIN] = 0x0;
            keyMap[s._PUK] = 0x0;
            s._PIN = _newPIN;
            s._PUK = _newPUK;
            keyMap[_newPIN] = SenderID;
            keyMap[_newPUK] = SenderID;
            s._PUK2a = _newPUK2a;
            s._PUK2b = _newPUK2b;
            s._PUK2c = _newPUK2c;
                
            resetIndex[SenderID] = ResetPUK(address(0), Sender(address(0),address(0),address(0),address(0),address(0)));
            emit resetPINPUK(SenderID, _newPIN, _newPUK, _newPUK2a, _newPUK2b, _newPUK2c);
            return true;
        } else {
            resetIndex[SenderID] = ResetPUK(address(0), Sender(address(0),address(0),address(0),address(0),address(0)));
            return false; // could add an event here to check to monitor wrong chagne claims
            }
        }
    //-----------------------------------------------End of the Account Management module-----------------------------------------------------

    //+++++++++++++++++++++++++++++++++++++++++++++++Start of the Contract Information Module++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    /**
    @dev determines the SenderID via the address (PIN or PUK)
    @dev the possibility to easlily get your SenderID increases the sender convenience
    @dev is needed for testing purposes, you have to kblock.timestamp the SenderID
     */
    function GetSenderID() external view returns(int64){
        return(keyMap[msg.sender]);
    }

    /**
    @dev returns the entire sender struct
    @dev has to be called by the PUK
    @dev is needed for testing purposes (backend) you have to check whether PIN and/or PUK got changed
    @param SenderID uint that identifies a specific sender (is constant)
     */
    function GetSenderInformation(int64 SenderID) public view returns(address, address, address, address, address){
        require (SenderID >= 0, "Must be a SenderID >= 0!"); 
        Sender storage s = senders[uint (SenderID)];
        //only the real sender or the BCP website can call his informations
        return(
            s._PIN,
            s._PUK,
            s._PUK2a,
            s._PUK2b,
            s._PUK2c
            );
    }
    
    /**
    @dev returns the PIN of the SenderID
     */
    function GetPIN(int64 SenderID) public view returns(address payable){
        require (SenderID >= 0, "Must be a SenderID >= 0!");
        Sender storage s = senders[uint (SenderID)];
        //only the real sender or the BCP website can call his informations
        return(s._PIN);
    }

    /**
    @dev returns the PUK of the SenderID
     */
    function GetPUK(int64 SenderID) public view returns(address payable){
        require (SenderID >= 0, "Must be a SenderID >= 0!");
        Sender storage s = senders[uint (SenderID)];
        //only the real sender or the BCP website can call his informations
        return(s._PUK);
    }
    
    //-----------------------------------------------End of the Account Management module-----------------------------------------------------

    //+++++++++++++++++++++++++++++++++++++++++++++++Start of the Contract Governance module++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
    The contract governance module consists of three functions:
    - Constructor: Authentication and initial registrations
    - Fallback: Recommended
    - Collect: Transfers any positive balance to the owner's address
    */

   //*************************************************Constructor******************************************************
   
    /**
    @dev registers BCP as SenderID-0
    @dev registers SenderID-1 through SenderID-3
     */
    constructor(address payable _PIN, address payable _PUK, address _PUK2a, address _PUK2b, address _PUK2c) {
        
        // 1. Authentication
        require (msg.sender == _PUK);
        
        // 2. Initial registration: BCP (SenderID-0)
        senders.push(Sender(_PIN, _PUK, _PUK2a, _PUK2b, _PUK2c));
        keyMap[_PIN] = 0;
        keyMap[_PUK] = 0;
        
        // 3. Initial registration: Random and random stuff (SenderID-1)
        senders.push(Sender(
            0x50dc646B7Aa3ddED162DfD801a35De89cAC7C1af,
            0x35228af8488F5FBA5161293fFa9fD6903aC19f88,
            0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21,
            0x03c10878054b5fc0DCd59c08E23940250220B20E,
            0x927F09B02C027B61D1477132440FEF3515EBe022)
        );
        keyMap[0x50dc646B7Aa3ddED162DfD801a35De89cAC7C1af] = 1;
        keyMap[0x35228af8488F5FBA5161293fFa9fD6903aC19f88] = 1;
        
        // 4. Initial registration: Financial Infos (SenderID-2)
        senders.push(Sender(
            0x053Cb36Ed183F76d1CbedA5B5Fe9BC57cA5B1a8A,
            0x2103a314d383c59Cfa31726516044b4e0458A22a,
            0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21,
            0x03c10878054b5fc0DCd59c08E23940250220B20E,
            0x927F09B02C027B61D1477132440FEF3515EBe022)
        );
        keyMap[0x053Cb36Ed183F76d1CbedA5B5Fe9BC57cA5B1a8A] = 2;
        keyMap[0x2103a314d383c59Cfa31726516044b4e0458A22a] = 2;
      
        // 5. Initial registration: Blockchain Infos (SenderID-3)
        senders.push(Sender(
            0xcF7a14be41D4fB6a4Dd39eb2dC4c0E2D74f5B0ff,
            0x074ccD50D1B9F2B20Bd6263418e32D0B1D390b30,
            0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21,
            0x03c10878054b5fc0DCd59c08E23940250220B20E,
            0x927F09B02C027B61D1477132440FEF3515EBe022)
        );
        keyMap[0xcF7a14be41D4fB6a4Dd39eb2dC4c0E2D74f5B0ff] = 3;
        keyMap[0x074ccD50D1B9F2B20Bd6263418e32D0B1D390b30] = 3;
    }

    fallback () external payable {
        emit fallbackCall(msg.sender, msg.value);
    }
    
    /**
    @dev transfers all collected payments from this contract to the owner
    */
    function Collect() external {
        require(msg.sender == senders[0]._PUK, "Not authorized!");
        senders[0]._PUK.transfer(address(this).balance);
    }

    //----------------------------------------------End of the Contract Governance module------------------------------------------------------
}
    //--------------------------------------------------------End of Contract------------------------------------------------------------------
