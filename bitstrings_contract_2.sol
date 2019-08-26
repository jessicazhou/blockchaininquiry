//under construction: previous method of generation was ineffective (storing empty strings)
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

    //there are 16 possible 4 bit bitstrings (or, continuing upwards in groups of 4?)
    //bitstring_map[0] corresponds to 0 in 4 bits
    string[16] bitstring_map = ['0000','0001','0010','0011','0100','0101','0110','0111','1000','1001','1010','1011','1100','1101','1110','1111'];
    
    // store "users" or accounts
    mapping(address => user) public users;
    mapping(address => bool) private userExists;
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
    function randomizer() public view returns (string) {
        uint random_number = uint(block.blockhash(block.number-1))%16; //0-15
        string bitstring = bitstring_map[random_number];
        return bitstring;
    }

    function random() public returns (uint) { //ERROR: no output
        uint random_number = uint(block.blockhash(block.number-1))%16; //0-15
        while(existingInts[random_number] != false){
            if(random_number == 15){
                random_number = 0;
            }
            else{
                random_number ++;
            }
        }
        existingInts[random_number] = true;
        return(random_number);
    }
    
    //keeps retrying if it number already exists
    function nonrepeat_randomizer(address acct_addr) private returns (string) { //TODO explore payable
        
        uint random_number = random();
        string bitstring = bitstring_map[random_number];
        
        //STORE!
        users[acct_addr] = user(acct_addr, bitstring);
            
        //post processing: store in a mapping for future existence checks, increment a count of bitstrings?
        //mark that they are now added!
        userExists[acct_addr] = true;
        userAndBitStringCount++;
       
            
        //trigger generatedEvent, pass in generated bitstring
        generatedEvent(bitstring);
       
    }
    

//////////MAIN FUNCTION//////////
    //what is the implication of this being a public function? the generate being independently called from the addUser() workflow?
    function generate (address acct_addr) public returns (string)  { 

        require(!userExists[acct_addr]);
        require(userAndBitStringCount < 16);//can carry out adding a user up until 15 users (max is 16)
        
        //generate bitstring and after checks (verify bitstring doesn't exist), stringify and set to user
        nonrepeat_randomizer(acct_addr);  //randomizer with crawler for repeats

    }
            
    event generatedEvent ( //for logging
        string indexed bitstring
    );
    
    
}
