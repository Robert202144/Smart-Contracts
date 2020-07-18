import "./ownable.sol";
import "./destruct.sol";

pragma solidity 0.6.2;

contract Hello2 is Ownable, Destroyable {
    struct Person {
        string name;
        uint age;
        uint height;
        bool senior;
    }
    
    // Create an event to help DApp listen for new additions to contract
        event personCreated(string name, bool senior);
    
    // Logs if person deleted and who by
        event personDeleted(string name, bool senior, address deletedBy);
    
    // add a balance state variable for the contract  
        uint public balance; 
    
    // Use cost modifier to simplify code, it will be executued in context of each function in which it is called
        modifier costs(uint cost) {
            require(msg.value <= cost); _;
        }

        
    // Create instances of the Person struct
        mapping(address => Person) private people; // restricting access so have to go through getter function, rather than automatic
        address[] private creators; // can only be accessed by the contract administrator
        
        // payable means the person can receive payment, but it costs 1 ether to add a person to this SC
        function createPerson(string memory name, uint age, uint height) public payable costs(1 ether) {
            require(age < 150, "Age needs to be less than 150"); // sanity check
            //require(msg.value >= 1 ether); // requires a value of more than 1 ether, but better to create a cost modifier if only 1 cost
            balance += msg.value;
            Person memory newPerson;
            newPerson.name = name;
            newPerson.age = age;
            newPerson.height = height;
            if (age >= 65) {
                newPerson.senior = true;
            }
            else{
                newPerson.senior = false;
            }
            
            insertPerson(newPerson);
            creators.push(msg.sender);
            // Check for conditions that should not happen (Invariant), and revert if occurs
            assert(
                keccak256(
                    abi.encodePacked(
                        people[msg.sender].name,
                        people[msg.sender].age,
                        people[msg.sender].height,
                        people[msg.sender].senior
                        )) 
                        ==
                keccak256(
                    abi.encodePacked(
                        newPerson.name,
                        newPerson.age,
                        newPerson.height,
                        newPerson.senior
                        ))
                );
            
            emit personCreated(newPerson.name, newPerson.senior); // will log into the console
        }
        
        // private helper function to simplify code:
        function insertPerson(Person memory newPerson) private {
            address creator = msg.sender;
            people[creator] = newPerson;
        }
        
        function getPerson() public view returns(string memory name, uint age, uint height, bool senior) {
            address creator = msg.sender; // could add payable if needed, but decision to make address not payable to minimize risk
            return (people[creator].name, people[creator].age, people[creator].height, people[creator].senior);
        }
        
        // to make an address payable user:
        // address payable test = address(uint160(creator));
        
        // require function validates the inputs to the function are correct before executing function
        function deletePerson(address creator) public onlyOwner{
            // owner == 0x82D304dC2Da739132b55caC3BfD6e30CF568c205 can delete
            // another address cannot:
            
            // staging memory to log a deletion event
            string memory name = people[creator].name;
            bool senior = people[creator].senior;
            
            // Delete operation
            delete people[creator];
            
            // check that deletion has occurred:
            assert(people[creator].age == 0);
            
            // log deletion events
            emit personDeleted(name, senior, msg.sender);
            
        }
        
        // modifier comes at the endof function definition but before returns..
        function getCreator(uint index) public view onlyOwner returns(address) {
            return creators[index];
        }
        // to calculate number of contract users
        function getLength() public view returns(uint length) {
            return creators.length;
        }
        // Allow owner of contract to withdraw money from it
        function withdrawFunds() public onlyOwner returns(uint funds) {
            uint toTransfer = balance; // create local variable of balance
            balance = 0; // Must reset balance state variable before actual withdrawel
            msg.sender.transfer(toTransfer); // If transfer fails balance will REVERT
            return toTransfer;
            // If use send method, the function completes but can be false so balance will not REVERT, so need to handle with if  / else statement to REVERT
            // if statement handling success:
            //if(msg.sender.send(toTransfer)){
                //return toTransfer;}
            //else {
                //balance = toTransfer;
                //return 0;}  // else statement handling failure
            
        }

}
