pragma solidity 0.6.2;

contract Ownable {
    
    address internal owner;

        
    constructor() public {
        owner = msg.sender;
        }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller needs to be owner"); _;
        }

}
