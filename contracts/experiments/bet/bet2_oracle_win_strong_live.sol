/// @custom:version compliant with the specification.

contract Bet {
  const address oracle
  const address player1
  const int deadline_join
  const int deadline_win

  address player2
  int state // 0 = JOIN-OR-TIMEOUT, 1 = WIN-OR-TIMEOUT, 2 = END
  
  constructor(address o, int dj, int dw) payable {
    require (msg.value==1 && dj<dw);
    player1 = msg.sender;
    oracle = o;
    deadline_join = dj;
    deadline_win = dw
  }

  function join() payable {
    require(state==0); // JOIN-OR-TIMEOUT
    require(block.number<deadline_join);
    require(msg.value==1);
	require (msg.sender != player1);
    state = 1; // WIN-OR-TIMEOUT2
    player2 = msg.sender
  }

  function timeout_join() {
    require(state==0); // JOIN-OR-TIMEOUT
    require(block.number>=deadline_join);
    state = 2; // END
    player1!1
  }

  function win(address winner) {
	require(state==1); // WIN-OR-TIMEOUT
	require(msg.sender==oracle);
    require(block.number<deadline_win);
	require(winner==player1 || winner==player2);
    state = 2; // END
    winner!balance
  }

  function timeout_win() {
	require(state==1); // WIN-OR-TIMEOUT
   	require(block.number>=deadline_win);
    state = 2; // END
	player1!1;
	player2!1
  }
}

// if deadline_join has passed and player2 has not joined, then anyone can make player1 redeem the bet 
property  oracle_win_strong_live {
    Forall xa
      [
        st.block.number<st.deadline_win && st.state==1 && st.balance >=2 
          -> 
        Exists tx [1, oracle]
        [
          ((app_tx_st.balance[player1] - st.balance[player1] >= 2) || (app_tx_st.balance[player2] - st.balance[player2] >= 2))
        ]
      ]
}

// if deadline_win has passed and the oracle has not chosen the winner, then anyone can make the players redeem their bets