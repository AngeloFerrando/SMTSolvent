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
    require (msg.value==1);
	  require (msg.sender != player1);
    state = 1; // WIN-OR-TIMEOUT2
    player2 = msg.sender
  }

  function timeout_join() {
    require(state==0); // JOIN-OR-TIMEOUT
    require(block.number>=deadline_join);
    state = 2; // END
    player1!1
    // FIXME: msg.sender!1
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
property any_timeout_join_live {
    Forall xa
      [
        st.block.number>=st.deadline_join && st.state==0 
          -> 
        Exists tx [1, xa]
        [
          (app_tx_st.balance[player1] - st.balance[player1] >= 1)
        ]
      ]
}

// once player2 has joiuned and before the deadline, the oracle can transfer the bet to one of the players
// WEAK UNSAT
property oracle_win_live {
    Forall xa
      [
        st.block.number<st.deadline_win && st.state==1 
          -> 
        Exists tx [1, oracle]
        [
          ((app_tx_st.balance[player1] - st.balance[player1] >= 2) || (app_tx_st.balance[player2] - st.balance[player2] >= 2))
        ]
      ]
}

// in state WIN-OR-TIMEOUT and before `deadline_win`, the oracle can transfer the whole pot to one of the players
// STRONG UNSAT
property oracle_win_strong_live {
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
property any_timeout_win_live {
    Forall xa
      [
        st.block.number>=st.deadline_win && st.state==1 && st.balance >=2 
          -> 
        Exists tx [1, xa]
        [
          ((app_tx_st.balance[player1] - st.balance[player1] >= 1) && (app_tx_st.balance[player2] - st.balance[player2] >= 1))
        ]
      ]
}

// (Can_Transactions_Arrive_Any_time=False WEAK SAT WEAK UNSAT)
property oracle_exact_balance_nonlive {
    Forall xa
      [
        st.block.number<st.deadline_win && st.balance==2 
          -> 
        Exists tx [1, oracle]
        [
          ((app_tx_st.balance[player1] - st.balance[player1] >= 2) || (app_tx_st.balance[player2] - st.balance[player2] >= 2))
        ]
      ]
}





/*
property {
    Forall xa  
      [block.number<deadline && balance==2 -> Exists s (s, xa) xa==oracle && can_withdraw(s,player1,2) || can_withdraw(s,player2,2)]
}

property {
    Forall xa  
      [block.number<deadline && balance==2 -> Exists tx . tx.msg.sender==oracle && can_withdraw(tx,player1,2) || can_withdraw(tx,player2,2)]
}


property {
  Forall st (implicito: stato reachable del contratto)
    Forall xa (non usato in questo esempio, ma in altri sì, ad es. Bank)
      [st.block.number<st.deadline && st.balance==2 -> Exists tx . tx.fun==win && tx.msg.sender==st.oracle && (((app tx st).balance(player1) - st.balance(player1) >= 2) || ((app tx st).balance(player2) - st.balance(player1) >= 2))]
}

property {
  Forall st (implicito: stato reachable del contratto)
    Forall xa (non usato in questo esempio, ma in altri sì, ad es. Bank)
      [st.block.number<st.deadline && st.balance==2 -> Exists tx . tx = oracle:win(player1) && tx.msg.sender==st.oracle && (((app tx st).balance(player1) - st.balance(player1) >= 2) || ((app tx st).balance(player2) - st.balance(player1) >= 2))]
}*/

//property {
//	forall xa  
//	    [block.number>timeout && balance==2 -> Exists s (s, xa) (can_withdraw(player1,1) && can_withdraw(player2,1))]
//}