pragma solidity ^0.8.0;

contract Oracle {
    
  Request[] requests; 
  uint currentId = 0; 
  uint minResults = 3; //minimum number of responses to receive before declaring final result
  uint totalOraclesCount = 5; // Hardcoded oracle count for now

  // general api request struct
  struct Request {
    uint id;                            
    string urlToQuery;                  
    string[] keys;            
    string agreedValue;               
    mapping(uint => string) resultsByOracles;  
    mapping(address => uint) oracles; 
  }

  //event that triggers oracle outside of the blockchain
  event NewRequest (
    uint id,
    string urlToQuery,
    string[] attributesToFetch
  );

  //triggered when there's a consensus on the final result
  event UpdatedRequest (
    uint id,
    string urlToQuery,
    string[] attributesToFetch,
    string agreedValue
  );

  function createRequest (
    string memory _urlToQuery,
    string[] memory _attributesToFetch
  )
  public
  {
    uint newreq;
    Request storage r = requests[newreq++];
    r.id = currentId;
    r.urlToQuery = _urlToQuery;
    r.keys = _attributesToFetch;
    r.agreedValue = "";
    uint length = requests.length;
    Request storage req = requests[length-1];

    // Hardcoded oracles address for now
    // 0 = not yet voted
    // 1= voted
    req.oracles[address(0x43B7734D9FA482684627F5E08832fa4A081Df156)] = 0;
    req.oracles[address(0x4Ed6c82574084CF2dDb36D91F1Ec570649D027D4)] = 0;
    req.oracles[address(0xa6E86C0E1FC0f98743dE3C443608a75Daed88351)] = 0;
    req.oracles[address(0x3f66b9A67cd83FC189f7150beDAce6A05f2e8545)] = 0;
    req.oracles[address(0x8F03Bbe8029CdAEfB98559157eDe54FC1E4BbA09)] = 0;
    
    emit NewRequest (
      currentId,
      _urlToQuery,
      _attributesToFetch
    );

    // increase request id
    currentId++;
  }


  function updateRequest (
    uint _id,
    string memory _valueRetrieved
  ) public {

    Request storage currRequest = requests[_id];

    //check if oracle is in the list of trusted oracles
    //and if the oracle hasn't voted yet
    if(currRequest.oracles[address(msg.sender)] == 0){

      //marking that this address has voted
      currRequest.oracles[msg.sender] = 1;

      //iterate through "array" of answers until a free position is found and save the retrieved value
      uint tmpI = 0;
      bool found = false;
      while(!found) {
        //find first empty slot
        if(bytes(currRequest.resultsByOracles[tmpI]).length == 0){
          found = true;
          currRequest.resultsByOracles[tmpI] = _valueRetrieved;
        }
        tmpI++;
      }

      uint currentOracle = 0;

      //iterate through oracle list and check if enough oracles(minimum agreements)
      //have voted the same answer has the current one
      for(uint i = 0; i < totalOraclesCount; i++){
        bytes memory a = bytes(currRequest.resultsByOracles[i]);
        bytes memory b = bytes(_valueRetrieved);

        if(keccak256(a) == keccak256(b)){
          currentOracle++;
          if(currentOracle >= minResults){
            currRequest.agreedValue = _valueRetrieved;
            emit UpdatedRequest (
              currRequest.id,
              currRequest.urlToQuery,
              currRequest.keys,
              currRequest.agreedValue
            );
          }
        }
      }
    }
  }
}
