import "./ownable.sol";
pragma solidity 0.6.2;

contract Destroyable is Ownable {
    function destroy () public onlyOwner { //onlyOwner is custom modifier
        selfdestruct(msg.sender);  // selfdestruct destroys the contract balance and sends to the owners address
}}
