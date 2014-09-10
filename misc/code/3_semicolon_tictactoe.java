public class ticFrame //3 semicolons
    extends javax.swing.JFrame implements java.awt.event.ActionListener {

  public static void main(String[] args) {

    if (new ticFrame(new javax.swing.JButton[12], new javax.swing.JLabel[1]).
        isVisible()) {
    }
  }

  public ticFrame(javax.swing.JButton[] BUT, javax.swing.JLabel[] jlbl) {

    if (xWins(true, 12, "", true, false, true, true, 0, true, BUT, true)) {}

  }

  public void actionPerformed(java.awt.event.ActionEvent e) {

    if (!this.getContentPane().getComponent(10).isVisible()) {
      if ( ( (javax.swing.JButton) e.getSource()).
          getText().
          equals("")) {
        if (e.getSource() ==
            ( (javax.swing.JButton)this.getContentPane().getComponent(0))) {
          if (xWins(false, 0, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(1))) {
          if (xWins(false, 1, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(2))) {
          if (xWins(false, 2, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(3))) {
          if (xWins(false, 3, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(4))) {
          if (xWins(false, 4, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(5))) {
          if (xWins(false, 5, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(6))) {
          if (xWins(false, 6, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(7))) {
          if (xWins(false, 7, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }
        else if (e.getSource() ==
                 ( (javax.swing.JButton)this.getContentPane().getComponent(8))) {
          if (xWins(false, 8, "X", false, false, true, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }

        if ( ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
            getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 0, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 0, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }

          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 1, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 1, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }

          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 2, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 2, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 3, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 3, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 4, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 4, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 5, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 5, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 6, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 6, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 7, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 7, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }
        else if ( ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
                 getText() == "") {
          //-------------Sets Text to O ---------------//
          if (xWins(!false, 8, "X", false, false, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {
            if (xWins(false, 8, "O", false, false, true, false, 0, false,
                      new javax.swing.JButton[12], false)) {}
          }
          //---------------------------------------//
        }

        //---Calls xWins without a semicolon---//
        if (xWins(false, 9, "O", false, false, false, false, 0, false,
                  new javax.swing.JButton[12], false)) {}
        //--------------------------------//
      }
    }

  }

  public boolean xWins(boolean h,
                       int greaterthan0, String player, boolean didanyonewin,
                       boolean maketie, boolean setText, boolean panache,
                       int resetwin, boolean init, javax.swing.JButton[] BUT,
                       boolean firsttime) {

    if (init == false) {
      if ( ( ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
            getText().equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
            getText().
            equals(player) ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
            getText().
            equals(player) &&
            ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
            getText().
            equals(player)) || maketie == true) {
        if (xWins(true, 11, "", false, false, true, true, 9, true, BUT, false)) {}
        if (xWins(true, 4, player + "Wins", true, false, true, true, 0, false,
                  new javax.swing.JButton[12], false)) {}

        if (h = h == h ? true : true) { /*sets h to true*/}

      }
      if ( ( ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
            getText().
            equals("X") ||
            ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
            getText().
            equals("O")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
           getText().
           equals("X") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
           getText().
           equals("O")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
           getText().
           equals("X") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
           getText().
           equals("O")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
           getText().
           equals("X") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
           getText().
           equals("O")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
           getText().
           equals("X") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
           getText().
           equals("O")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
           getText().
           equals("O") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
           getText().
           equals("X")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
           getText().
           equals("O") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
           getText().
           equals("X")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
           getText().
           equals("X") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
           getText().
           equals("O")) &&
          ( ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
           getText().
           equals("X") ||
           ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
           getText().
           equals("O")) && didanyonewin == false) {
        if (! ( ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
               getText().equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
               getText().
               equals("X") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("X") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
               getText().
               equals("X")) ||
            ! ( ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
               getText().equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(3)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(1)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(7)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(5)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(0)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(8)).
               getText().
               equals("O") ||
               ( (javax.swing.JButton)this.getContentPane().getComponent(2)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(4)).
               getText().
               equals("O") &&
               ( (javax.swing.JButton)this.getContentPane().getComponent(6)).
               getText().
               equals("O"))
            ) {
          if (xWins(true, 3, "Nobody", true, true, false, false, 0, false,
                    new javax.swing.JButton[12], false)) {}
        }

      }
      if (setText == true) {

        if (xWins(true, (greaterthan0 + 1), player, false, false, true, true,
                  greaterthan0, true, BUT, false)) {}
        if (this.getContentPane().getComponent(10).isVisible() && resetwin == 0) {
          if (xWins(true, 0, "The", true, false, true, true, 1, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 1, "Game", true, false, true, true, 1, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 2, "is", true, false, true, true, 11, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 3, "Over", true, false, true, true, 10, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 5, "Make", true, false, true, true, 10, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 6, "Your", true, false, true, true, 10, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 7, "Time", true, false, true, true, 10, false,
                    new javax.swing.JButton[12], false)) {}
          if (xWins(true, 8, "hahaha", true, false, true, true, 10, false,
                    new javax.swing.JButton[12], false)) {}
        }

      }
    }
    else {
      if (firsttime == true) {
        if ( (BUT[0] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[1] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[2] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[3] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[4] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[5] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[6] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[7] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[8] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[9] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[10] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
        if ( (BUT[11] = true ? new javax.swing.JButton() :
              new javax.swing.JButton()) == null) {}
      }
      else {
        if ( (BUT[0] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(0)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(0))) == null) {}
        if ( (BUT[1] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(1)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(1))) == null) {}
        if ( (BUT[2] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(2)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(2))) == null) {}
        if ( (BUT[3] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(3)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(3))) == null) {}
        if ( (BUT[4] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(4)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(4))) == null) {}
        if ( (BUT[5] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(5)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(5))) == null) {}
        if ( (BUT[6] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(6)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(6))) == null) {}
        if ( (BUT[7] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(7)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(7))) == null) {}
        if ( (BUT[8] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(8)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(8))) == null) {}
        if ( (BUT[9] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(9)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(9))) == null) {}
        if ( (BUT[10] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(10)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(10))) == null) {}
        if ( (BUT[11] = true ?
              ( (javax.swing.JButton)this.getContentPane().getComponent(11)) :
              ( (javax.swing.JButton)this.getContentPane().getComponent(11))) == null) {}

      }
      for (int i = 0; i <= 0;
           this.getContentPane().setLayout(new java.awt.GridLayout(4, 3)),
           ( (javax.swing.JButton) BUT[0]).addActionListener(this),
           ( (javax.swing.JButton) BUT[1]).addActionListener(this),
           ( (javax.swing.JButton) BUT[2]).addActionListener(this),
           ( (javax.swing.JButton) BUT[3]).addActionListener(this),
           ( (javax.swing.JButton) BUT[4]).addActionListener(this),
           ( (javax.swing.JButton) BUT[5]).addActionListener(this),
           ( (javax.swing.JButton) BUT[6]).addActionListener(this),
           ( (javax.swing.JButton) BUT[7]).addActionListener(this),
           ( (javax.swing.JButton) BUT[8]).addActionListener(this),
           ( (javax.swing.JButton) BUT[9]).addActionListener(this),
           ( (javax.swing.JButton) BUT[10]).addActionListener(this),
           ( (javax.swing.JButton) BUT[11]).addActionListener(this),
           this.getContentPane().add( (javax.swing.JButton) BUT[0]),
           this.getContentPane().add( (javax.swing.JButton) BUT[1]),
           this.getContentPane().add( (javax.swing.JButton) BUT[2]),
           this.getContentPane().add( (javax.swing.JButton) BUT[3]),
           this.getContentPane().add( (javax.swing.JButton) BUT[4]),
           this.getContentPane().add( (javax.swing.JButton) BUT[5]),
           this.getContentPane().add( (javax.swing.JButton) BUT[6]),
           this.getContentPane().add( (javax.swing.JButton) BUT[7]),
           this.getContentPane().add( (javax.swing.JButton) BUT[8]),
           this.getContentPane().add( (javax.swing.JButton) BUT[9]),
           this.getContentPane().add( (javax.swing.JButton) BUT[10]),
           this.getContentPane().add( (javax.swing.JButton) BUT[11]),
           setSize(1000, 700), setTitle("My game has panache"),
           setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE),
           setVisible(true),

           BUT[0].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[1].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[2].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[3].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[4].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[5].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[6].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[7].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[8].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[9].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[10].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           BUT[11].setFont(new java.awt.Font("Vivaldi", java.awt.Font.BOLD, 42)),
           repaint(), BUT[greaterthan0 - 1].setText(player),
           BUT[greaterthan0 - 1].setVisible(h),
           i++) {

      }
      if (didanyonewin) {
        if (xWins(false, 12, "", false, false, true, true, 9, true, BUT, false)) {}
        if (xWins(false, 11, "", false, false, true, true, 9, true, BUT, false)) {}
        if (xWins(false, 10, "", false, false, true, true, 9, true, BUT, false)) {}
      }

    }
    return h;
  }
}
