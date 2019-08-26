pragma solidity ^0.4.2;

//need to do a check on bitstrings that already exist
    //the total number of 4-bit-strings assigned and the number of un-used 4-bit-strings remaining
    //generate a new random bit-strings
    
    /*
    Constraints: (1) each user can be assigned max 1 bitstring, 
    (2) every user's bitstring must be unique (i.e. no re-using bitstrings), and 
    (3) there must be a public method called "generate(user)" 
        which associates an unused, random, 4-bit bistring for the user and stores it in public data storage.
    */

contract Bitstrings {
    
//////////CONTRACT VALUES//////////
    struct user {
        address id;
        string bitstring;
    }
    
    // store "users" or accounts
    mapping(address => user) public users;
    mapping(address => bool) private userExists;
    mapping(string => bool) private bitstrings; //bitstrings doesnt !!
    mapping(uint => bool) private existingInts; //for internal checking purposes
    
    // store user count - proxy for bitstring count as well
    uint public userAndBitStringCount = 0;
    

//////////CONSTRUCTOR//////////
    function Bitstrings () public {
        //executes upon call
        generate(msg.sender); //upon deployment of contract, address/account that deploys is stored (?)
    }
    
    
//////////HELPER CONVERSION FUNCTIONS//////////
    function bytes32toBytesArray (bytes32 data) private pure returns (bytes) {
        bytes memory bytesArray = new bytes(32);
        for (uint j=0; j<32; j++) {
          byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
          if (char != 0) {
            bytesArray[j] = char;
          }
        }
        return bytesArray;
    }
    
    function bytes32toBytes1(bytes32 b) private pure returns(uint) {
        return uint(b);
    }
    
    
//////////RANDOMIZER FUNCTIONS////////// 
    function random() public returns (uint8) { //ERROR: no output
        return uint8((uint256(keccak256(block.timestamp, block.difficulty))+1)%251); //do i need to have +1 in case starts as 0?
        //check conversion: test with hardcoded value 
    }

    function randomizer() public view returns (string) {
        //random int
        uint random_int = (random() + 1)% 17;
        
        //int to bytes32
        bytes32 random_bytes = bytes32(random_int); 
        
        //ultimately, iterate through two byte arrays to build iteratively, then convert to string 
        //how do we get there?
        bytes memory random_bytes32Array= bytes32toBytesArray(random_bytes);
        bytes memory result = new bytes(32);
        
        uint256 startIndex = 28;
        uint256 endIndex = 31; //we want the last 4 digits of a 32 bit integer
        for(uint256 i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = random_bytes32Array[i]; //result and test_byte need to be bytes w index access
        }
         string memory test_return = string(result);
         return test_return; 
    }
    
    //keeps retrying if it number already exists
    function nonrepeat_randomizer() private returns (string) { //TODO explore payable
        //random int
        uint random_int = (now + 15 )% 16; // %16 yields numbers 0-15, and +15 ensures we don't don't get a div by 0 error
        
        while(existingInts[random_int] == true){
            if(random_int == 16){
                random_int=0;
            }
            random_int ++;
        }
        existingInts[random_int] = true;
        
        //int to bytes32
        bytes32 random_bytes = bytes32(random_int); 
        
        //ultimately, iterate through two byte arrays to build iteratively, then convert to string 
        bytes memory random_bytes32Array= bytes32toBytesArray(random_bytes);
        bytes memory result = new bytes(32);
        
        uint256 startIndex = 28;
        uint256 endIndex = 31;
        for(uint256 i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = random_bytes32Array[i]; //result and test_byte need to be bytes w index access
        }
        
        return string(result); 
       
    }
    

//////////MAIN FUNCTION//////////
    //what is the implication of this being a public function? the generate being independently called from the addUser() workflow?
    function generate (address acct_addr) public returns (string)  { 

        require(!userExists[acct_addr]);
        require(userAndBitStringCount < 16);//can carry out adding a user up until 15 users (max is 16)
        
            //generate bitstring and after checks (verify bitstring doesn't exist), stringify and set to user
            //note memory vs storage
            string memory random = nonrepeat_randomizer();  //randomizer with crawler for repeats
            
            //STORE!
            users[acct_addr] = user(acct_addr, random);
            
            //post processing: store in a mapping for future existence checks, increment a count of bitstrings?
            //mark that they are now added!
            userExists[acct_addr] = true;
            userAndBitStringCount++;
            bitstrings[random] = true;
            
            //trigger generatedEvent, pass in generated bitstring
            generatedEvent(random);
    }
            
    event generatedEvent ( //for logging
        string indexed bitstring
    );
    
    
}
