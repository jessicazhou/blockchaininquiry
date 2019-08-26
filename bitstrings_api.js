
//https://ethereum.stackexchange.com/questions/45620/how-to-build-an-api-that-communicate-with-smart-contract-event reading and subscribing to events
//get user's bitstring
//get total 4 bit strings assigned /unused
//post request to generate new random bitspring

const Web3 = require('web3')

const rpcURL = 'https://ropsten.infura.io/v3/2fd4c6046d2146a184e319c529c49ebf' //infura: we deployed to ropstein testnet so we want this one
const address = '0x655d00a3d135e232d1f576726b4f415cb9a477b0' //here is address of most recently reployed contract as seen in remix
//deployment at: https://ropsten.etherscan.io/tx/0x3f383a855132e67e02e1e5e9f90f773e4adf4715d9b5697b3b79cdf8cfede8cb#eventlog

const web3 = new Web3(rpcURL)

//abi is a json array that desribes how a specific smart contract works, update everytime i recompile (see remix ide)
//address of smart contract 
const abi = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "acct_addr",
				"type": "address"
			}
		],
		"name": "generate",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "userAndBitStringCount",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "random",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "users",
		"outputs": [
			{
				"name": "id",
				"type": "address"
			},
			{
				"name": "bitstring",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [],
		"name": "randomizer",
		"outputs": [
			{
				"name": "",
				"type": "string"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"name": "bitstring",
				"type": "string"
			}
		],
		"name": "generatedEvent",
		"type": "event"
	}
]

const contract = new web3.eth.Contract(abi, address) //javascript representation of ethereum smart contract

//we could log contract.methods to the console, and see what's returned 
contract.methods

//[works] get total 4bitstrings assigned /unused -- need to now also return the unused (16 - returned number)
contract.methods.userAndBitStringCount().call((err, result) => {console.log(result)}) //yields assigned, then find unused

//[works] get user's bitstring; my metamask ropsten test account #3 
contract.methods.users(0xBDc0Dd8f0A1824Be89800501eCcE04692E09E436).call((err, result) => {console.log(result.bitstring)}) 
//contract.methods.users(0xD2C910C98fb872040f1025B0DEa2d3BF276C0394).call((err, result) => {console.log(result.bitstring)}) 

//[works] post request to generate new random bitspring 
contract.methods.randomizer().call((err, result) => { console.log(result) }) //or for any other address

