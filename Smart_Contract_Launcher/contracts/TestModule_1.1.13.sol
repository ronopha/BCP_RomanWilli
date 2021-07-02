pragma solidity >=0.7.0 <0.8.0; 
//SPDX-License-Identifier: UNLICENSED

/* BCP Parent Contract "BCP_informed.sol"
   Copyright (c) 2019-2020 Blockchain Presence
   To order data from Blockchain Presence: 
   
     (1) Import this file into your Solidity file.
     
     (2) Let your contract inherit the abstract contract "BCP_informed".
        
     (3) Use the view function GetTransactionCosts to determine the accurate ETH value for the function call. 
     
     (4) Let one of your functions call the ORDER function. 
       
     (5) Implement the Mailbox function in your smart contract.
     
     (6) Doublecheck that the modifier "onlyBCP" is added to your implementation of the Mailbox function.
    
   Example: 
      
     pragma solidity >=0.6.0 <0.7.0; 
     
     import "https://github.com/BlockchainPresence/Blockchain-Project/blob/master/Version%201.1.10%20(active)/Use%20Cases/BCP_informed.sol"

     contract yourContract is BCP_informed {
        
         function Mailbox(uint _orderID, int88 _data, bool _statusFlag) override external payable onlyBCP {
         ...
         }
         
         uint32 orderID = BCP.ORDER.value(BCP.GetTransactionCosts(_commitmentID,_gasForMailbox)) (_commitmentID,_gasForMailbox,_location,_orderDate);
      }
    
*/    
//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.8.0; 

interface BCP_interface {
    function ORDER(int64 commitmentID, uint40 _gasForMailbox, string calldata _location, uint32 _orderDate) external payable returns(uint32);      
    function GetTransactionCosts(int64 _commitmentID, uint40 _gasForMailbox) external view returns(uint);
}

abstract contract BCP_informed {
    //address payable constant BCP_Address = 0xeEba0a5b81575C5dF6669783bAF6b989bF6a20e4
    BCP_interface BCP;// = BCP_interface(BCP_Address);
    address payable public BCP_Address;    
    modifier onlyBCP {
        require(msg.sender==BCP_Address);
        _;
    }
 
    event ReceiverConnection(address Rec, address indexed SC);

    constructor(address payable addr) {
        emit ReceiverConnection(msg.sender,address(this));
        BCP_Address = addr;
        BCP = BCP_interface(addr);
    }
    function getBCPAddr() external view returns (address payable) {
        return BCP_Address;
    }
    function Mailbox(uint32 _orderID, int88 _data, bool _statusFlag) virtual external payable;

    fallback() virtual payable external; 

}


contract BCP_TestModule is BCP_informed{

    /**
    @notice emitted when a new test run was called 
    @param orderID uint that identifies a specific order 
    @param orderTime uint that specifies that point in time when the order arrived 
    */
    event ReportOrder(
        uint32 orderID,
        uint32 orderTime
        );
    
    /**
    @notice emitted when a test run was successful 
    @param orderID uint that identifies a specific order
    @param _data ordered data
    @param _statusFlag states whether delivery is valid
    @param _gasLeft remaining amount of gas 
    @param _deliveryTime uint that specifies that point in time when the ordered data point arrived
    */
    event ReportDelivery(
        uint32 orderID,
        int88  _data,
        bool   _statusFlag, 
        uint64 _gasLeft,
        uint32 _deliveryTime
        );
    constructor(address payable addr) BCP_informed(addr) {}
    //--------------------------------------------------------------------------------------------------------------------
    /**
    @notice calls BCP_Order 
     */
    function TestOrder(int64 _commitmentID, string memory _location) public payable returns(uint32){ 
        uint40 _gasForMailbox = 200000; 
        uint transactionCost = BCP.GetTransactionCosts(_commitmentID, _gasForMailbox);
        require(transactionCost<msg.value,"need more money");
        uint32 orderID = BCP.ORDER{value: transactionCost} (_commitmentID, _gasForMailbox, _location, uint32(block.timestamp));       
        emit ReportOrder(orderID, uint32(block.timestamp)); 
        return(orderID);                                  
    }

    /**
    @notice receives the data 
     */
    function Mailbox(uint32 orderID, int88 _data, bool _statusFlag) public payable override onlyBCP{
        emit ReportDelivery(orderID, _data, _statusFlag, uint64(gasleft()), uint32(block.timestamp));
    }

    /**
    @notice makes sure the Relay function doesn't crash if _statusFlag is false
    */
    fallback() payable external override {}

}