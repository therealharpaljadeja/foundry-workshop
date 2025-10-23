// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MessageBoard.sol";

contract DeployMessageBoard is Script {
    function run() external returns (MessageBoard) {
        string memory initialMessage = "Welcome to Monad!";
        
        vm.startBroadcast();
        
        MessageBoard messageBoard = new MessageBoard(initialMessage);
        
        vm.stopBroadcast();
        
        console.log("MessageBoard deployed to:", address(messageBoard));
        console.log("Initial message:", messageBoard.message());
        
        return messageBoard;
    }
}

