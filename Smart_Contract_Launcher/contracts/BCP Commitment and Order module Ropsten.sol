// Copyright (c) 2019-2020 Blockchain Presence
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0;

/**
The Blockchain Presence smart contract consists of three modules:
- Overrule
- Order & Delivery
- Contract Governance
 */

interface BCPRegistrationRopsten_interface {
    function GetPUK(int64) external view returns(address payable); 

    function GetPIN(int64) external view returns(address payable); 

    function GetSenderInformation(int64 SenderID) external view returns(address, address, address, address, address);
}


contract BCPCommitmentandOrderRopsten {

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
        address  payable _PIN;
        address  payable _PUK;
        address  _PUK2a;
        address  _PUK2b;
        address  _PUK2c;
    }

    /**
    @dev stores the Commitment information
    @param SenderID uint that identifies a specific sender (is constant)
    @param _horizon the date until when a sender commits himself (in epochtime)
    @param _senderFee stores the fee that is required
    @param _gasPrice sets the gas Price for the delivery process
    @param _descriptionHash is the hashed description of the .xlsx file
     */
    struct Commitment {
        int64  SenderID;
        uint32  _horizon;
        uint64  _senderFee;
        uint64  _gasPrice;
        bytes32 _descriptionHash;
    }

    /**
    @dev stores the order information
    @param _deliveryAddress is the receivers address
    @param commitmentID uint that identfies the senders most recent .xlsx file
    */
    struct Order {
        address payable _deliveryAddress;
        int64  commitmentID;
    }

//*************************************************Arrays*************************************************************
    
    Commitment[] public commitments;
    Commitment[] public commitmentsTest;
    Sender[] senders;
    Order[] orders;

//*************************************************Mappings************************************************************

    /**
    @dev maps PIN and PUK to SenderID
    NOTE: ensures that different SenderIDs have different PINs and that PINs are not used as PUKs
    */
    mapping(address => int64) keyMap;
    
    /**
    @dev maps a senderID to related commitments
     */ 
    mapping(int64 => int64[]) public comMap;

//*******************************************Global Variables and Constructor********************************************

    BCPRegistrationRopsten_interface public BCPRegistration;
    uint public BCPGross; //set to be 0 per default
    // Hash that identifies the ABI of the Mailbox function
    bytes4  constant BCP_Mailbox = bytes4(keccak256("Mailbox(uint32,int88,bool)"));
    uint40 constant _gasForRelay = 40000;

    /**
    @dev sets the BCPGross to be 0
    @dev defines the initial safe low
    @dev defines the owner to be the message sender
     */
    constructor(address _addr) {
        BCPRegistration = BCPRegistrationRopsten_interface(_addr);
        require (msg.sender == BCPRegistration.GetPUK(0)); 
        
        // Initial commitment: The BCP owner and Website (void commitment, fill in 0) (senderID-0)        
        commitments.push(Commitment(0, 0, 0, 0, 0));  
        commitmentsTest.push(Commitment(0, 0, 0, 0, 0));   

        // Initial commitment: Random and random stuff (SenderID-1)    

        commitments.push(Commitment(1, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x77fafae1cc291a96a61a79128bd472577082c88c8d20d5201010960dbd699b68));  //0 Random
        commitments.push(Commitment(1, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x79813451690fccbd9031b3fc4b8e5c2bed5c5676769f7f28063695d0d1daec37));  //1 White Ether
        commitments.push(Commitment(1, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x266c16d18acf2c6dee1c6f3ca5c4cee08b938663fe266456c3b56ea9c8adb2a5));  //2 SBB Abfahrt
        commitments.push(Commitment(1, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x2b5d7785e6849a450c68a3ac02d016589dc10684aaf8898e8fdfa3059940dd24));  //3 SBB Ankunft
        commitments.push(Commitment(1, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0xb7f60f0919988154d7dc59e2cda32697eb27422bd617213731c6ad002d2ecd4d));  //4 Temperature and Humidity


        // Initial commitment: Financial Infos (SenderID-2)


        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x87ecaf907fda1db16da65f41bf1b28455acc570ae3d94b74c8a553b86377295c)); //5 BTC/ETC                       
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x9c27e5bb7785826e02978c338ba68a27786dbb4b7f8e66b3976ea5820a54bbbc)); //6 Wechselkurse (Fiat und Crypto)                         
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x304eeba5286743392277b5dbe80a35d45f90b53b7e3beb882810efd3e9f8c795)); //7: US Stocks prices (letzte, oder historical Schlusskurs)
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0xd702600f64d0607b84ee7ea7d5076ca166ee4673e5785a9a644ab9480561f12a)); //8: SIX Stocks prices (letzte Schlusskurs)
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x3cb09e106c947e0d481f6d72fa2e433fe2b5927d1bd8a142dd58ba0aafa6eebf)); //9: Company metrics wie EBITDA, EPS, market Cap, ROE usw. von US Company
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x492cbd5102da88017e9b4827181adad600fdb1bcfeeb9e76472e44faede943e3)); //10: SAR kurs (SARON, SARTN, SAR1W usw) von der SNB
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0xfed8cd391589d0a42f6d8507814bcca836fad539ca2962e6f4c6cc4b27bf976c)); //11: Spot interest rates with different maturities for SWISS Confederation Bond 
        commitments.push(Commitment(2, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0xbb12aa3564726bc979935ee19d7b6fe16aee301071612a3e9bd5ce73fb7ebb9d)); //12: Metals preis (Gold, Silver, Platinum. Palladium)
        
        // Initial commitment: Blockchain Infos (SenderID-3)

        
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x3d7890c831b559be718d67f1eb71243611a63eed977998035d60adecb551e6dc));  //13: aktuelle preis von irgendeine Cryptocurrency               
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x899a6732dee50dbeae1ea2df8f5c432c887d89cf122781d1eff6dc52449e9ca3));  //14: Coins infos wie market Cap, volume, supply, market cap rank
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x5cb0313b5a7beee21d901d004f18886aaa160e16d08ce31c8295d32f1104c0c0));  //15: Reccommended gas price for each transaction speed (ETH Gas Station)
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x23967581be8b37cb139d1d754b5dd8b8b68392c7fb56c1bc3dcf11e98652fbe0));  //16: Waiting Time for each speed (ETH GAS Station)
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0xf8ffc3e2b6b5457109a93512cb2bc8b197b8efed73b2cbc427a8f4312a875574));  //17: Account Balance von eine Adresse in eine der folgende Blockchain (btc, eth, ltc, dash oder doge)             
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x8d5b83c35ecad1633ecc075f606d3e03e5c4a2b54e671d4d48b4397988e8d7c0));  //18: Average Transaction cost for transaction mined within 3-6 blocks (  btc, eth, ltc, dash oder doge)
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0x041d786c6077dcb430715b3c888adc89302445bf521ed7d9dbc20ac486fc5ab7));  //19: Nr. of blocks (btc, eth, ltc, dash oder doge)               
        commitments.push(Commitment(3, uint32(block.timestamp + 60 days), 500000 gwei, uint64(12 gwei), 0xf7b3b1e5b7ff652c32e0c56864602f045ab7d0df0943d7de78a1ffb82033d618));  //20: Nr. of unconfirmed transactions (btc, eth, ltc, dash oder doge                  
    }

//*************************************************Events************************************************************

    /**
    @param SenderID uint that identifies a specific sender (is constant)
    @param commitmentID uint that identfies the senders most recent .xlsx file
     */
     event newCommitment(
        int64  SenderID,
        int64  commitmentID
        );

    /**
    @param _PIN is the senders main address
    @param orderID uint that identifies a specific order
    @param commitmentID uint that identfies the senders most recent .xlsx file
    @param _location is the position (column and row) in the .xlsx file
    @param _orderDate date on which the order should arrive (in epochtime)
    @param _gasForDelivery is the total amount of gas that is available for the delivery process
    @param _gasPrice sets the gas Price for the delivery process
    @param condition checks whether the order date is within the commitment horizon
    @param receiverAddress is the address of the receiver 
     */
    event newOrder(
        address indexed _PIN,
        uint32  orderID,
        int64  commitmentID,
        string  _location,
        uint32  _orderDate,
        uint40  _gasForDelivery,
        uint64  _gasPrice,
        bool    condition,
        address receiverAddress
    );

    /**
    @param orderID uint that identifies a specific order
    @param _statusFlag is a control variable that shows if the incoming transaction contains the datapoint
    @param _status shows whether the oder is open or closed
     */
    event dataDelivered(
        uint32  orderID,
        bool    _statusFlag,
        bool    _status
    );

    /**
    @param CustomerAddress is the address that called the fallback function
    @param MonetaryAmount is the msg.value that was provided within the call
     */
    event fallbackCall(
        address CustomerAddress,
        uint    MonetaryAmount
    );
    
    /**
    @param horizon is the new expire date 
    @param commitmentID int that identfies the senders most recent .xlsx file 
    */
    event horizonExtension(
        uint32 horizon,
        int64 commitmentID
    );
    
//+++++++++++++++++++++++++++++++++++++++++++++++++++++Start of the Overrule module+++++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
    @dev allows to copy new commitments from the mainnet
    @param SenderID uint that identifies a specific sender (is constant)
    @param _horizon the date until when a sender commits himself (in epochtime)
    @param _senderFee sets the fee that is required to be paid within the order process
    @param _gasPrice sets the gas Price for the delivery process of that .xlsx file
    @param _descriptionHash sets the identification parameter for the commited data
     */
    function OverruleNewCommitment(
        int64 _commitmentID, 
        int64 SenderID, 
        uint32 _horizon, 
        uint64 _senderFee, 
        uint64 _gasPrice, 
        bytes32 _descriptionHash
    ) 
        external 
        returns (int64)
    {
        //can only be called from the BCP website
        require(msg.sender == BCPRegistration.GetPIN(0) , "Not authorized!");
        int64 commitmentID = _commitmentID; 
        int16 emptySpace = int16(uint(commitmentID)-commitments.length); 
        if(emptySpace>=0){
            while (emptySpace>0){
                commitments.push(Commitment(0, 0, 0, 0, 0x0));
                emptySpace--; 
            }
            commitments.push(Commitment(SenderID, _horizon, _senderFee, _gasPrice, _descriptionHash));
        }
        else {
            commitments[uint(commitmentID)] = Commitment(SenderID, _horizon, _senderFee, _gasPrice, _descriptionHash);
        }
 
        return(commitmentID);
    }
    
     /**
    @dev allows to copy new horizons regarding commitments from the mainnet
    @param _commitmentID uint that identfies the senders most recent .xlsx file  
    @param _newHorizon the date until when a sender commits himself (in epochtime)
     */
    function OverruleHorizonExtension(int64 _commitmentID, uint32 _newHorizon) external {
        //can only be called from the BCP website
        require(msg.sender == BCPRegistration.GetPIN(0), "Not authorized!");
        commitments[uint(_commitmentID)]._horizon = _newHorizon;
    }
    
    function OverruleElevateCommitment(uint64 _index, int64 _commitmentID, int64 _senderID) external {
        //can only be called from the BCP website
        require(msg.sender == BCPRegistration.GetPIN(0), "Not authorized!");
        Commitment storage c = commitmentsTest[uint(-_commitmentID)];
        comMap[c.SenderID][_index] = 0;
        c.SenderID = _senderID;
    }

//-----------------------------------------------------End of the Overrule module----------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++++++++Start of the Commitment module+++++++++++++++++++++++++++++++++++++++++++++++++++++++

       /**
    @dev sets up new commitments for .xlsx files
    @param _SenderID: Sowohl Test als auch Main SenderID
    @param _horizon the date until when a sender commits himself (in epochtime)
    @param _senderFee sets the fee that is required to be paid within the order process
    @param _gasPrice sets the gas Price for the delivery process of that .xlsx file
    @param _descriptionHash sets the identification parameter for the commited data
     */
   function NewCommitment(
        int64 _SenderID, 
        uint32 _horizon, 
        uint64 _senderFee, 
        uint64 _gasPrice, 
        bytes32 _descriptionHash
    ) 
        external 
        returns(int64) 
    {
        if (_SenderID>=0) {
        // Unterscheidung, welcher _PUK herausgelesen wird! 
        require(msg.sender == BCPRegistration.GetPUK(_SenderID), "Not authorized!"); // TO BE CHECKED
        }
        else {
        require(msg.sender == BCPRegistration.GetPUK(_SenderID), "Not authorized!");
        }
        
        require(_horizon >= block.timestamp, "Horizon must be in the future");
        
        // fees for data must be reasonable by law
        require(_senderFee <= 1 ether, "Fee must be below 1 ether");

        int64 commitmentIDTest = int64(-(commitmentsTest.length)); // commitments.length int or uint?
        commitmentsTest.push(Commitment(
                _SenderID,
                _horizon,
                _senderFee,
                _gasPrice,
                _descriptionHash));
        comMap[_SenderID].push(commitmentIDTest);
        emit newCommitment(_SenderID, commitmentIDTest);
        return(commitmentIDTest);
    }
    
    function HorizonExtension(int64 _commitmentID, uint32 _newHorizon) external {
        require(_commitmentID <  0, "Must be a negative commitmentID!");
        int64 SenderID = commitmentsTest[uint(-_commitmentID)].SenderID;
        require(msg.sender == BCPRegistration.GetPUK(SenderID), "Not authorized!");
        commitmentsTest[uint(-_commitmentID)]._horizon = _newHorizon;
        emit horizonExtension(_newHorizon, _commitmentID);
    }

//-----------------------------------------------------End of the Commitment module----------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++Start of the Order & Delivery module++++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
    The order & delivery module consists of nine order functions and the Relay function:
    The order functions differ in the number of function arguments:
    - GetTransactionCosts: Determines the transaction costs
    - GeneralOrder: Is the only order function that contains the hole function body
    - Relay: Receives the incoming data and transfers it to the final receiver and substracts the fee from the original payment of the receiver.
    */

    // This function allows the receiver to determine the value that needs to be attached to the ORDER transaction
    function GetTransactionCosts(int64 _commitmentID, uint40 _gasForMailbox) external view returns (uint) {
        require( _commitmentID != 0);
        if (_commitmentID > 0) { 
            uint _gasprice = commitments[uint(_commitmentID)]._gasPrice;
            uint _senderFee = commitments[uint(_commitmentID)]._senderFee;
            return((_gasForMailbox+_gasForRelay)*_gasprice+_senderFee);
        } else {
            uint _gasprice = commitmentsTest[uint(_commitmentID)]._gasPrice;
            uint _senderFee = commitmentsTest[uint(_commitmentID)]._senderFee;
            return((_gasForMailbox+_gasForRelay)*_gasprice+_senderFee);
        }
    }
    
    /**
    @dev general order function for customized orders
    @param commitmentID uint that identifies a specific commitment
    @param _gasForMailbox is the maximum of gas that is available for the delivery process (set by the receiver)
    @param _location is the position (column and row) in the .xlsx file
    @param _orderDate date on which the order should arrive (in epochtime)
     */
    function ORDER(
        int64 commitmentID, 
        uint40 _gasForMailbox, 
        string calldata _location, 
        uint32 _orderDate
    ) 
        external 
        payable 
        returns (uint32) 
    {
        // 1. Order analysis
        require( commitmentID != 0);
        Commitment memory c;
        if (commitmentID > 0) {
            c = commitments[uint(commitmentID)];
        } else {
            c =  commitmentsTest[uint(-commitmentID)];
        }
        int64 SenderID = c.SenderID;
        uint32 OrderID  = uint32(orders.length);
        bool condition = (_orderDate <= c._horizon);
        uint40 _gasForDelivery = _gasForMailbox + _gasForRelay;
        uint _gasCost = _gasForDelivery*c._gasPrice;
        int delta = int(msg.value)- int(_gasCost+c._senderFee);
        if (delta > 0){BCPGross += uint(delta);}
        // 2. Reporting to website
        emit newOrder(
           BCPRegistration.GetPIN(SenderID), // senders[uint(SenderID)]._PIN, analog maincontract, is it working?
            OrderID,
            commitmentID,
            _location,
            _orderDate,
            _gasForDelivery,
            c._gasPrice,
            condition,
            msg.sender);
        // 3. Checking incoming order
        require(condition,"Order date is below the commitment horizon");
        require(delta >= 0, "Insufficient funds for Relay transaction");
        // 4. Fueling delivery
        BCPRegistration.GetPIN(SenderID).transfer(_gasCost);
        // 5. Storing order
        orders.push(Order(
            msg.sender,
            commitmentID));
        return(OrderID);
    }

    /**
    @dev receives the final data and collects the fee
    @param orderID uint that identifies a specific order (is constant)
    @param _data is the finally requested information behind the order
    @param _statusFlag is a control variable that shows if the incoming transaction contains the datapoint
     */
    function Relay(uint32 orderID, int88 _data, bool _statusFlag) external payable {
        // 1. On-Chain authentication
        // TO BE DISCUSSED, wie soll man +/- SenderID/commitmentID unterscheiden? IS THIS CORRECT??
        
        Order memory o = orders[orderID];        
        Commitment memory c;
        if (o.commitmentID>=0) {
            c = commitments[uint(o.commitmentID)];
        } else {
            c =  commitmentsTest[uint(-o.commitmentID)];
        }

        require(msg.sender == BCPRegistration.GetPIN(c.SenderID), "Not authorized!"); 
        //if the order is already finished the o._deliveryAddress is 0x000000...
        require(o._deliveryAddress != address(0), "order already delivered");
        // 2. Delivery
        delete orders[orderID];
        (bool sent, ) =  o._deliveryAddress.call(abi.encodeWithSelector(BCP_Mailbox, orderID, _data, _statusFlag));
        emit dataDelivered(orderID, _statusFlag, sent);
        // 3. Compensation
        uint64 _fee = c._senderFee;
        if(_fee > 0){
            if(_statusFlag){
                    BCPRegistration.GetPUK(c.SenderID).transfer(_fee/2);
                    BCPGross += _fee/2;
                } else {
                o._deliveryAddress.transfer(_fee);
                }
            }
   }

    /**
    @dev necessary to be able to display the receiver address on our webpage
    @param orderID uint that identifies a specific order (is constant)
     */
    function GetReceiverFromOrderID(uint32 orderID) public view returns (address) {
        require(msg.sender == BCPRegistration.GetPUK(0), "Not authorized!");
        return(orders[orderID]._deliveryAddress);
    }

    /**
    @dev returns the hole sender struct
    @dev has to be called by the PUK
    @dev is needed for testing purposes (backend) you have to check whether PIN and/or PUK got changed
    @param SenderID uint that identifies a specific sender (is constant)
     */
    function GetSenderInformation(int64 SenderID) public view returns(address, address, address, address, address) {
        (address _PIN, address _PUK, address _PUK2a, address _PUK2b, address _PUK2c) = BCPRegistration.GetSenderInformation(SenderID);
        //only the real sender or the BCP website can call his informations
        return(
            _PIN,
            _PUK,
            _PUK2a,
            _PUK2b,
            _PUK2c
        );        
    }    
    
//------------------------------------------------End of the Order & Delivery module-------------------------------------------------------

//+++++++++++++++++++++++++++++++++++++++++++++++Start of the Contract Governance module++++++++++++++++++++++++++++++++++++++++++++++++++++

    /**
    The contract governance module consists of two functions:
    - Collect: Transfers the BCPGross balance to the owners address.
    */

    /**
    @dev transfers all collected payments from this contract to the owner
     */
    function Collect() external{
        require(msg.sender == BCPRegistration.GetPUK(0), "Not authorized!");
        BCPRegistration.GetPUK(0).transfer(BCPGross);
        BCPGross = 0;
    }

    fallback() external payable {
        BCPGross += msg.value;
        emit fallbackCall(msg.sender, msg.value);
    }

//----------------------------------------------End of the Contract Governance module------------------------------------------------------
}
//--------------------------------------------------------End of Contract------------------------------------------------------------------
