contract C14 {
  bool b

  constructor () {
    b = False;
    skip
  }

  function unlock() {
    require(not b); 
    b = true
  }

  function pay(amount) {
    require (amount <= balance && b);
    b = False;
    sender ! amount
  }

}