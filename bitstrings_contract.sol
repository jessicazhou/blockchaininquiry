pragma solidity ^0.4.2;

contract Bitstrings {
    // Model a user
    struct user {
        uint id;
        string bitstring;
    }
    
    // store "users" or accounts
    mapping(address => user) users;
   mapping(address => bool) userExists;
    mapping(string => bool) bitstrings;
    mapping(uint => bool) existingInts;
    
    // store user count - proxy for bitstring count as well
    uint public userAndBitStringCount = 0;
    
    //need to do a check on bitstrings that already exist
    //the total number of 4-bit-strings assigned and the number of un-used 4-bit-strings remaining
    //generate a new random bit-strings
    
    /*
    Constraints: (1) each user can be assigned max 1 bitstring, 
    (2) every user's bitstring must be unique (i.e. no re-using bitstrings), and 
    (3) there must be a public method called "generate(user)" 
        which associates an unused, random, 4-bit bistring for the user and stores it in public data storage.
    */

    function Bitstrings () public {
        //executes upon call
        //addUser(msg.sender);
    }
    
    //helper conversion function
    function bytes32toBytesArray (bytes32 data) pure private returns (bytes) {
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
    
    
  function addUser(address acct_addr) private { //expected behavior: runs through the workflow of adding a user upon interaction with a contract
         // require that they haven't been stored + assigned a bitstring before
        require(!userExists[acct_addr]);
        
        //can't add any more users past 16?
        if(userAndBitStringCount < 16){ //can carry out adding a user up until 15 users (max is 16)
            //mark that they are now added!
            userExists[acct_addr] = true;
        
            //update user count
            userAndBitStringCount++;
            
            //generate a code
            generate(acct_addr);
        }
    }    

    function randomizer() public constant returns (string) {
        //random int
        uint random_int = (now + 16 )% 17;
        
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
    function nonrepeat_randomizer() private constant returns (string) {
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
        //how do we get there?
        bytes memory random_bytes32Array= bytes32toBytesArray(random_bytes);
        bytes memory result = new bytes(32);
        
        uint256 startIndex = 4;
        uint256 endIndex = 7;
        for(uint256 i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = random_bytes32Array[i]; //result and test_byte need to be bytes w index access
        }
        
         return string(result); 
    }
    
        
    event generatedEvent ( //for logging
        string indexed bitstring
    );
    
    
    //what is the implication of this being a public function? the generate being independently called from the addUser() workflow?
    function generate (address acct_addr) public returns (string)  { //some repeat checks in the instance that generate is called independently of addUser, 
            //check again: //if they are a new user, generate a bitstring for them
            require(userAndBitStringCount< 16); //up to 15 users, we can add one more (max 16, max 16 bitstrings)
            require(!userExists[acct_addr]);
        
            //generate bitstring and after checks (verify bitstring doesn't exist), stringify and set to user
            //note memory vs storage
            string memory random = nonrepeat_randomizer();  //randomizer with crawler for repeats
            //api function doesn't have a nonrepeat constraint, so that is randomizer()
            
            //post processing: store in a mapping for future existence checks, increment a count of bitstrings?
            bitstrings[random] = true;
            
            //trigger generatedEvent, pass in generated bitstring
            generatedEvent(random);

    }
    
    
}
