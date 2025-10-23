// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MessageBoard {
    string public message;
    address public author;
    uint256 public messageCount;
    
    event MessageUpdated(address indexed author, string message, uint256 timestamp);
    
    constructor(string memory _initialMessage) {
        message = _initialMessage;
        author = msg.sender;
        messageCount = 1;
    }
    
    function updateMessage(string memory _newMessage) public {
        require(bytes(_newMessage).length > 0, "Message cannot be empty");
        message = _newMessage;
        author = msg.sender;
        messageCount++;
        
        emit MessageUpdated(msg.sender, _newMessage, block.timestamp);
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    function getAuthor() public view returns (address) {
        return author;
    }
}

