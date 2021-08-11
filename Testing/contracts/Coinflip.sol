//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "../../BCP_informed.sol";

contract Coinflip is BCP_informed {
    
    address payable[2] participants;
    uint pot;
    
    event winner(address,uint);
    
    // Connection to the BCP Oracle
    constructor(address payable addr) BCP_informed(addr) {}
    
    // Calls the commitment 22 in the BCP Oracle for a random number 0 or 1 
    function flipCoin(address payable playerTwo) external payable {
        participants[0] = msg.sender;               
        participants[1] = playerTwo;                
        uint40 _gasForMailbox = 200_000;
        
        // Gets the cost of ordering and devlivering the data
        uint transactionCost = BCP.GetTransactionCosts(22, _gasForMailbox); 
        pot = msg.value - transactionCost;
        
        // Orders the random number from the BCP Oracle
        BCP.ORDER{value: transactionCost}(22, _gasForMailbox, "A1", uint32(block.timestamp));                                                                           // between 0 and 1
    }
    
    // The BCP Oracle calls this function and delivers the requested data
    function Mailbox(uint32 _orderID, int88 _data, bool _statusFlag) external payable override onlyBCP {
        require(_statusFlag = true); 
        address payable winnerAddr = participants[uint(_data)];
        emit winner(winnerAddr, pot);
        winnerAddr.transfer(pot);
    }
    
    fallback() payable external override{}
}
