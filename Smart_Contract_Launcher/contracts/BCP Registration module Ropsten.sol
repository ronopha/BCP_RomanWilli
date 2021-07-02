// Copyright (c) 2019-2020 Blockchain Presence
// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.7.0 <0.8.0;

/**
The Blockchain Presence smart contract consists of three modules:
- Overrule
- Order & Delivery
- Contract Governance
 */
contract BCPRegistrationRopsten {

//*************************************************Structs************************************************************

    /**
    @dev stores all sender addresses
    @param _PIN is the SCAs main address
    @param _PUK is the senders main address
    @param _PUK2a first of the PUK2 triplet. Is held by the sender
    @param _PUK2b second of the PUK2 triplet. Is held by the first trusted party
    @param _PUK2c third of the PUK2 triplet. Is held by the second trusted party
    */

    struct Sender {
        address payable _PIN;
        address payable _PUK;
        address _PUK2a;
        address _PUK2b;
        address _PUK2c;
    }

    /**
    @dev stores the PUK2 triplet for comparison reasons in the ResetPINPUK function
    @param _claimant stores the address that calls the ResetPINPUK function
    @param Sender is the nested Sender struct
    */
    struct ResetPUK {
        address payable _claimant;
        Sender _newSender;
    }

//*************************************************Arrays*************************************************************

    Sender[] private senders;
    Sender[] private sendersTest;
    
//*************************************************Mappings************************************************************

    /**
    @dev maps PIN and PUK to senderID
    NOTE: ensures that different senderIDs have different PINs and that PINs are not used as PUKs
    */
    mapping(address => int64) keyMap;

    /**
    @dev maps senderID to ResetPUK
    NOTE: recalls last claim for reset (if any)
    */
    mapping(int64 => ResetPUK) resetIndex;
    
    /**
    @dev maps PIN and PUK to senderID
    NOTE: ensures that different senderIDs have different PINs and that PINs are not used as PUKs
    */
    mapping(address => int64) keyMapTest;

    /**
    @dev maps senderID to ResetPUK
    NOTE: recalls last claim for reset (if any)
    */
    mapping(int64 => ResetPUK) resetIndexTest;

//*******************************************Global Variables and Constructor********************************************

    /**
    @dev defines the BCP owner as SenderID-3
    @dev defines SenderID-0 - SenderID-2
     */
    constructor(
        address payable _PIN, 
        address payable _PUK, 
        address _PUK2a, 
        address _PUK2b,
        address _PUK2c) {
        require(msg.sender == _PUK);
        
        // 1 szabo = 10^12 wei

       // Initial registration: The BCP owner and Website (senderID-0)
        senders.push(Sender(_PIN,
                         _PUK,
                         _PUK2a,
                         _PUK2b,
                         _PUK2c));

        keyMap[_PIN] = 0;
        keyMap[_PUK] = 0;

        sendersTest.push(Sender(_PIN,
                         _PUK,
                         _PUK2a,
                         _PUK2b,
                         _PUK2c));

        keyMapTest[_PIN] = 0;
        keyMapTest[_PUK] = 0;

        // Initial registration & commitment: Christian (senderID-1)
        senders.push(Sender(
            0x50dc646B7Aa3ddED162DfD801a35De89cAC7C1af,
            0x35228af8488F5FBA5161293fFa9fD6903aC19f88,
            0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21,
            0x03c10878054b5fc0DCd59c08E23940250220B20E,
            0x927F09B02C027B61D1477132440FEF3515EBe022)
        );

        keyMap[0x50dc646B7Aa3ddED162DfD801a35De89cAC7C1af] = 1;
        keyMap[0x35228af8488F5FBA5161293fFa9fD6903aC19f88] = 1;

        // Initial registration & commitment: Financial Infos (senderID-2)
        senders.push(Sender(
            0x053Cb36Ed183F76d1CbedA5B5Fe9BC57cA5B1a8A,
            0x2103a314d383c59Cfa31726516044b4e0458A22a,
            0x4384A01045CCB9cAEBb75d9423C2F49FaFffAc21,
            0x03c10878054b5fc0DCd59c08E23940250220B20E,
            0x927F09B02C027B61D1477132440FEF3515EBe022)
        );

        keyMap[0x053Cb36Ed183F76d1CbedA5B5Fe9BC57cA5B1a8A] = 2;
        keyMap[0x2103a314d383c59Cfa31726516044b4e0458A22a] = 2;

        // Initial registration & commitment: Blockchain Infos (senderID-3)
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
        int64  SenderID,
        address PIN,
        address PUK,
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
    @param senderID uint that identifies a specific sender (is constant)
    @param PIN is the main address
     */
    event newClaim(
        int64 senderID,
        address PIN,
        address PUK,
        address PUK2a,
        address PUK2b,
        address PUK2c
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
    
    /**
    @param CustomerAddress is the address that called the fallback function
    @param MonetaryAmount is the msg.value that was provided within the call
     */

    event fallbackCall(
        address CustomerAddress,
        uint MonetaryAmount
        );
        
//+++++++++++++++++++++++++++++++++++++++++++++++++++++Start of the Overrule module+++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    /**
    The Overrule module consists of five functions that can only be called by the BCP website to copy your data from the Ehereum mainnet. 
    - SetNewSender: Copies the senders from the mainnet
    - SetChangePIN: Copies the new PIN address regarding the senderID in case one has been changed on the mainnet
    - SetResetPINPUK: Copies the new addresses regarding the senderID in case they have been chnaged in the mainnet
    - SetNewCommitment: Copies the commitments from the mainnet
    - SetHorizonExtension: Cpoies the new horizon regarding a commitment in case one has been changed on the mainnet
     */

    /**
    @dev allows to copy new senders from the mainnet
    @param _senderID uint that identifies a specific sender (is constant) 
    @param _PIN is the SCAs main address
    @param _PUK is the senders main address
    @param _PUK2a first of the PUK2 triplet. Is held by the sender
    @param _PUK2b second of the PUK2 triplet. Is held by the first trusted party
    @param _PUK2c third of the PUK2 triplet. Is held by the second trusted party
     */
    function OverruleNewSender(
        int64 _senderID, 
        address payable _PIN, 
        address payable _PUK, 
        address _PUK2a, 
        address _PUK2b, 
        address _PUK2c
    ) 
        external 
        returns (int64)
    {
        //can only be called from the BCP website 
        require(msg.sender == senders[0]._PIN, "Not authorized!");
        require(keyMap[_PIN] == 0x0, "PIN already in use");
        require(keyMap[_PUK] == 0x0, "PUK already in use");
        int64 senderID = _senderID; 
        int16 emptySpace = int16(uint(senderID)-senders.length); 
        address payable emptyAddress = 0x0000000000000000000000000000000000000000;
        if (emptySpace>=0) {
            while (emptySpace>0){
                senders.push(Sender(emptyAddress, emptyAddress, emptyAddress, emptyAddress, emptyAddress));
                emptySpace--; 
            }
            senders.push(Sender(_PIN, _PUK, _PUK2a, _PUK2b, _PUK2c));
        } else {
            senders[uint(senderID)] = Sender(_PIN, _PUK, _PUK2a, _PUK2b, _PUK2c);
        }
        
        keyMap[_PIN] = senderID;
        keyMap[_PUK] = senderID;
        return(senderID);
    }


    /**
    @dev allows to copy the new PIN address in case one has been changed 
    @param senderID uint that identifies a specific sender (is constant)
    @param _newPIN alternative PIN for the deleted one
    */
    function OverruleChangePIN(int64 senderID, address payable _newPIN) external {
        //can only be called from the BCP website
        require(msg.sender == senders[0]._PIN, "Not authorized!"); 
        Sender storage s = senders[uint(senderID)];// mit if else statement lösen? Dann würde es nur zwei Funktionen geben. 
        keyMap[s._PIN] = 0x0;
        s._PIN = _newPIN;
        keyMap[_newPIN] = senderID;
    }

    /**
    @dev allows to copy new sender addresses in case they have been changed
    @param senderID uint that identifies a specific sender (is constant)
    @param _newPIN new PIN address
    @param _newPUK new PUK address
    @param _newPUK2a new PUK2a address
    @param _newPUK2b new PUK2b address
    @param _newPUK2c new PUK2c address
     */
    function OverruleResetPINPUK(
        int64 senderID, 
        address payable _newPIN, 
        address payable _newPUK, 
        address _newPUK2a, 
        address _newPUK2b, 
        address _newPUK2c
    ) 
        external 
        returns(bool)
    {
        require(msg.sender == senders[0]._PIN, "Not authorized!"); 
        // PIN or PUK? Must be website? --> Overrule functions called by website should be PIN!!
        //can only be called from the BCP website
        Sender storage s = senders[uint(senderID)];
        keyMap[s._PIN] = 0x0;
        keyMap[s._PUK] = 0x0;
        s._PIN = _newPIN;
        s._PUK = _newPUK;
        keyMap[_newPIN] = senderID;
        keyMap[_newPUK] = senderID;
        s._PUK2a = _newPUK2a;
        s._PUK2b = _newPUK2b;
        s._PUK2c = _newPUK2c;
        return true;
    }
    
    /**
    @dev allows to copy new horizons regarding commitments from the mainnet
    @param _senderID int64 that identfies the senders
     */
    function OverruleDeactivateSender(int64 _senderID) external {
        require(msg.sender == senders[0]._PIN, "Not authorized!");
        Sender storage s = sendersTest[uint(-_senderID)];
        keyMapTest[s._PIN] = 0;
        keyMapTest[s._PUK] = 0;
        sendersTest[uint(-_senderID)] = Sender(address(0), address(0), address(0), address(0), address(0));
    }
//-----------------------------------------------------End of the Overrule module----------------------------------------------------------

//++++++++++++++++++++++++++++++++++++++++++++++++++Start of the Account Management module++++++++++++++++++++++++++++++++++++++++++++++++++


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
        address _PUK2c
    ) 
        public 
        returns (int64)
    {
        require(msg.sender == _PUK, "Not authorized!");
        //checks that the PUK, PUK2a, PUK2b and PUK2c are different addresses
        require(
            _PIN != _PUK &&
            _PIN != _PUK2a &&
            _PIN != _PUK2b &&
            _PIN != _PUK2c, "PIN can't be PUK/PUK2a/PUK2b/PUK2c"
            );
        require(keyMapTest[_PIN] == 0x0 , "PIN already in use");
        require(keyMapTest[_PUK] == 0x0, "PUK already in use");
        //creates SenderID and stores the sender information
        //notice that the first element within the array has the ID 0 since arrays start to count from 0
        int64 SenderIDTest = int64(-(sendersTest.length)); // senders.length also int64?
        //-(sendersTest.length) würde nun einen negativen SenderID erstellen. +1 wegen 0 (senderID-0)
        sendersTest.push(Sender( // sendersTest korrekt???
            _PIN,
            _PUK,
            _PUK2a,
            _PUK2b,
            _PUK2c));
        //create dependency PIN / PUK -> SenderID
        keyMapTest[_PIN] = SenderIDTest;
        keyMapTest[_PUK] = SenderIDTest;
        emit newSender(SenderIDTest, _PIN, _PUK, _PUK2a, _PUK2b, _PUK2c);
        return(SenderIDTest);
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
        external 
        returns (int64)
    {
        int64 SenderIDTest = NewSenderPro(_PIN, _PUK, _PUK, _PUK, _PUK); // analog main, braucht es diese?
        return(SenderIDTest);
    }

   /**
    @dev allows to copy the new PIN address in case one has been changed 
    @param _newPIN alternative PIN for the deleted one
    */
    // needs an if else statement to be able to change the PIN of senderIDTest and senderID or not?
    function ChangePIN(address payable _newPIN) external {
        int64 senderID = keyMapTest[msg.sender];
        require(msg.sender == sendersTest[uint(-senderID)]._PIN, "Not authorized!"); // -senderID correct? or without "-"?
        Sender storage s = sendersTest[uint(-(senderID))]; 
        keyMapTest[s._PIN] = 0x0;
        s._PIN = _newPIN;
        keyMapTest[_newPIN] = senderID;
        emit PINChanged(senderID, _newPIN);
    }

     //@dev returns false if claim, 1 if PINPUK changed
    function ResetPINPUK(
        int64 SenderID, 
        address payable _newPIN, 
        address payable _newPUK, 
        address _newPUK2a, 
        address _newPUK2b, 
        address _newPUK2c
    )
        external 
        returns (bool) 
    {
        require (SenderID <= 0, "Must be a SenderID <=0!");
        Sender storage s = sendersTest[uint(-SenderID)];
        ResetPUK storage r = resetIndexTest[SenderID]; 
    // 1. Authentication
        require ((msg.sender == s._PUK2a) || (msg.sender == s._PUK2b) || (msg.sender == s._PUK2c), "sender must be either PUK2a, PUK2b or PUK2c");
    // 2. Check formal correctness
        require (_newPIN != _newPUK, "new PIN cannot be equal to new PUK");
    // 2.1 Further Authentication
        require ( msg.sender != r._claimant, "to approve the claim you have to use another address of the PUK2a/PUK2b/PUK2c triplet!"); 
    // 3. Case distinction
        if (s._PUK == s._PUK2a && 
            s._PUK == s._PUK2b && 
            s._PUK == s._PUK2c) {
                keyMapTest[s._PIN] = 0x0;
                keyMapTest[s._PUK] = 0x0;
                s._PIN = _newPIN;
                s._PUK = _newPUK;
                keyMapTest[_newPIN] = SenderID;
                keyMapTest[_newPUK] = SenderID;
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
            emit newClaim(
                SenderID, 
                _newPIN, 
                _newPUK, 
                _newPUK2a,
                _newPUK2b, 
                _newPUK2c);
            return false;
        } else if (_newPIN == r._newSender._PIN && 
            _newPUK == r._newSender._PUK && 
            _newPUK2a == r._newSender._PUK2a && 
            _newPUK2b == r._newSender._PUK2b && 
            _newPUK2c ==r._newSender._PUK2c) {
            keyMapTest[s._PIN] = 0x0;
            keyMapTest[s._PUK] = 0x0;
            s._PIN = _newPIN;
            s._PUK = _newPUK;
            keyMapTest[_newPIN] = SenderID;
            keyMapTest[_newPUK] = SenderID;
            s._PUK2a = _newPUK2a;
            s._PUK2b = _newPUK2b;
            s._PUK2c = _newPUK2c;
            resetIndexTest[SenderID] = ResetPUK(address(0), Sender(address(0),address(0),address(0),address(0),address(0)));
            emit resetPINPUK(SenderID, _newPIN, _newPUK, _newPUK2a, _newPUK2b, _newPUK2c);
            return true;
        } else {
            resetIndexTest[SenderID] = ResetPUK(address(0), Sender(address(0),address(0),address(0),address(0),address(0)));
            return false;
        }
    }
 
    /**
    @dev determines the SenderID via the address (PIN or PUK)
    @dev the possibility to easlily get your SenderID increases the sender convenience
    @dev is needed for testing purposes, you have to kblock.timestamp the SenderID
     */
    function GetSenderID() external view returns (int64) {
        if (keyMapTest[msg.sender] == 0) {
            return(keyMap[msg.sender]);
        }
        return(keyMapTest[msg.sender]);
    }

    /**
    @dev returns the hole sender struct
    @dev has to be called by the PUK
    @dev is needed for testing purposes, you have to check whether PIN and/or PUK got changed
    @param SenderID uint that identifies a specific sender (is constant)
     */
    function GetSenderInformation(int64 SenderID) public view returns(
        address, 
        address, 
        address, 
        address, 
        address)
        { // SCA function: Same funciton Name
        Sender storage s;
        if (SenderID >0) {
            s = senders[uint(SenderID)];
        } else {
            s = sendersTest[uint (-(SenderID))];
        }
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
    @dev returns the PUK of the SenderID
     */
    function GetPUK(int64 SenderID) public view returns (address payable) {
        Sender memory s;
        if (SenderID>=0) {
            s = senders[uint (SenderID)];
        } else {
            s = sendersTest[uint(-SenderID)];
        }
        return(s._PUK);
    }
    
    /**
    @dev returns the PIN of the SenderID
     */ 
    function GetPIN(int64 SenderID) public view returns (address payable) {
        Sender memory s;
        if (SenderID >= 0) {
            s = senders[uint (SenderID)];
        } else {
            s = sendersTest[uint(-SenderID)];
        }
        return(s._PIN);
    }
    
    /**
    @dev Get the senderID of an address, only BCP can use this function
    */
    function getSenderFromAddr(address _addr) external view returns (int64 senderID) {
        require(msg.sender == senders[0]._PIN, "Not authorized!");
        senderID = keyMapTest[_addr];
        return(senderID);
    }
    
//-----------------------------------------------------End of the Account Management module----------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++Start of the Contract Governance module++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
    The contract governance module consists of two functions:
    - Collect: Transfers the BCPGross balance to the owners address.
    */

    /**
    @dev transfers all collected payments from this contract to the owner
     */
     

    function Collect() external {
        require(msg.sender == senders[0]._PIN, "Not authorized!");
        senders[0]._PIN.transfer(address(this).balance);
    }

    fallback() external payable {
        emit fallbackCall(msg.sender, msg.value); 
    }

//----------------------------------------------End of the Contract Governance module------------------------------------------------------
}
//--------------------------------------------------------End of Contract------------------------------------------------------------------