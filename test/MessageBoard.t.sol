// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MessageBoard.sol";

contract MessageBoardTest is Test {
    MessageBoard public messageBoard;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    
    function setUp() public {
        messageBoard = new MessageBoard("Hello Monad!");
    }
    
    function test_InitialMessage() public view {
        assertEq(messageBoard.message(), "Hello Monad!");
        assertEq(messageBoard.messageCount(), 1);
    }
    
    function test_UpdateMessage() public {
        vm.prank(user1);
        messageBoard.updateMessage("New message from user1");
        
        assertEq(messageBoard.getMessage(), "New message from user1");
        assertEq(messageBoard.getAuthor(), user1);
        assertEq(messageBoard.messageCount(), 2);
    }
    
    function test_MultipleUpdates() public {
        vm.prank(user1);
        messageBoard.updateMessage("First update");
        
        vm.prank(user2);
        messageBoard.updateMessage("Second update");
        
        assertEq(messageBoard.getMessage(), "Second update");
        assertEq(messageBoard.getAuthor(), user2);
        assertEq(messageBoard.messageCount(), 3);
    }
    
    function test_RevertEmptyMessage() public {
        vm.expectRevert("Message cannot be empty");
        messageBoard.updateMessage("");
    }
    
    function test_EmitEvent() public {
        vm.expectEmit(true, false, false, false);
        emit MessageBoard.MessageUpdated(address(this), "Test event", block.timestamp);
        
        messageBoard.updateMessage("Test event");
    }
}

