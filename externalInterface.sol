pragma solidity 0.5.12;

    // Interface contains function headers needed in the interface
    //interface contains the definitions of a contract and its functions, but not the full code
    // remove cost modifier as it requires just  the definition / header part of the implementation

contract Hello2{
    function createPerson(string memory name, uint age, uint height) public payable;
}

    // create instance of type Hello2  which is defined in interface above and the location is provided
    // modification to function call with another.value modifier and then add the instance modifier
contract externalContract {
    
    Hello2 instance = Hello2(0x95336228de1487A32A6Ca1E4bDa7Dbfb9552a5Ca);
    
    function externalCreatePerson(string memory name, uint age, uint height) public payable {
        instance.createPerson.value(msg.value)(name, age, height); 
    }
}
