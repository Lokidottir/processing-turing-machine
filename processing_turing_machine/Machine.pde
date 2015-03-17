/*
    Fionan Haralddottir
    Turing Machine in Processing
    March 2015
*/

import java.lang.Integer;

final int WRITE_STATE = 0;
final int  MOVE_STATE = 1;
final int  GOTO_STATE = 2;

final int MOVE_IMMEDIATE = 0;
final int MOVE_GRADUAL   = 1;

final int HALTED_STATENUM = Integer.MAX_VALUE;

boolean PRINT_TM_STATE = false;

class TMachine {
    TMProgram program;         //Program that the turing machine is running
    int       statenum;        //The index of the state that the turing machine is at
    int       decision_state;  //The state of the decision that is being executed (0: write, 1: move, 2: goto)
    boolean   decision_mode;   //The mode of the decision, true for executing if code, false for executing else.
    Tape      tape;            //The bi-directional tape that the machine is operating on
    int       tape_index;      //The index of the Turing Machine's head on the tape
    boolean   halted;          //The halted state of the Turing Machine, if true then no code is executed
    int       move_mode;       //The movement mode, immediate (eg. 1 -> 2500 in 1 step) or gradual (eg. 1 -> 2 -> ... -> 2500 in 2499 steps)
    boolean   in_motion;       //The boolean representing the turing machine's being in motion, only relevent if movement mode is gradual
    int       moves_made;      //Integer representing how many moves have been made, until moving to goto. only relevent if movement mode is gradual

    TMachine() {
        this.statenum       = 0;            //Set the state as 0, as this is the initial starting state
        this.decision_state = WRITE_STATE;  //Set the decision state to write, as this is executed in the order write -> move -> goto
        this.decision_mode  = true;         //Set the decision mode as true arbitrarily
        this.tape           = new Tape();   //Construct a new tape for the turing machine to act on
        this.tape_index     = 0;            //Set the tape index at 0
        this.halted         = false;        //Set the machine as not halted
        this.move_mode      = MOVE_GRADUAL; //Set the move to gradual, as this makes more sense for a "proper" turing machine emulation
        this.moves_made     = 0;            //Set the moves made to 0
    }

    TMachine(TMProgram program) {
        this();                 //Call other constructor
        this.program = program; //Set the program as the one provided as the parameter
    }

    void step() {
        /*
            Do a step in the program, one "step" is the execution of a
            write, move or goto segment of a decision.
        */
        if (this.halted) {
            return; //close, as the machine is halted.
        }
        else {
            /*
                perform a single operation (write, move, or goto) and then exit.
            */
            if (PRINT_TM_STATE) println("d_state: " + this.decision_state + " staten: " + this.statenum + " moves made: " + this.moves_made + " d_mode: " + this.decision_mode + " t_index: " + this.tape_index);
            switch (this.decision_state) {
                case WRITE_STATE:
                    this.decision_mode = this.tape.read(this.tape_index);
                    boolean to_write;
                    if (this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).write_tape < 0) to_write = this.tape.read(this.tape_index);
                    else to_write = this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).write_tape != 0;
                    this.tape.write(this.tape_index, to_write);
                    this.decision_state = MOVE_STATE;
                    break;
                case MOVE_STATE:

                    if (this.move_mode == MOVE_IMMEDIATE) {
                        this.tape_index += this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).move_head;
                        this.decision_state = GOTO_STATE;
                    }
                    else if (this.move_mode == MOVE_GRADUAL) {
                        /*
                            The move is gradual, so move one bit in the direction of the move each step.
                        */
                        int moves_needed_to_make = ceil(abs(this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).move_head));
                        if (this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).move_head != 0 && this.moves_made < moves_needed_to_make) {
                            this.tape_index += (this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).move_head < 0 ? -1 : 1);
                            this.moves_made++;
                        }
                        if (this.moves_made >= moves_needed_to_make) {
                            this.moves_made = 0;
                            this.decision_state = GOTO_STATE;
                        }
                    }
                    else {
                        println("[TMachine.step] unrecognised movement mode: " + this.move_mode + ", halting program.");
                        this.halted = true;
                    }
                    break;
                case GOTO_STATE:
                    this.statenum = this.program.getStateByStatenum(this.statenum).getDecisionByBoolean(this.decision_mode).goto_state;
                    //println("[TMachine.step] goto state " + this.statenum);
                    this.decision_state = WRITE_STATE;
                    if (this.statenum == HALTED_STATENUM) this.halted = true;
                    break;
            }
        }
    }

    void superstep() {
        /*
            Execute an entire state of the program
        */
        if (this.halted) {
            return; //return as the machine is halted
        }
        else if (this.decision_state == WRITE_STATE) {
            this.step();      //perform a single step, moving the state beyond WRITE_STATE
            this.superstep(); //call recursively for the final case.
        }
        else {
            //As the program may be in movement, keep stepping until we are at the write state again.
            while (this.decision_state != WRITE_STATE && !this.halted) this.step();
        }
    }

    int currentState() {
        return this.statenum;
    }

}

class Tape {
    /*
        Bi-directional bit tape
    */
    ArrayList<Byte> positive_bittape;
    ArrayList<Byte> negative_bittape;
    boolean default_state;

    Tape() {
        this.positive_bittape = new ArrayList<Byte>();
        this.negative_bittape = new ArrayList<Byte>();
        this.default_state = false;
    }

    Tape(boolean[] tape_init) {
        this();
        for (int i = 0; i < tape_init.length; i++) {
            this.write(i,tape_init[i]);
        }
        print("(tape) loaded tape as: ");
        for (int i = 0; i < this.size(); i++) {
            print(this.read(i) ? 1 : 0);
        }
        println("");
    }

    Tape(final Tape tape) {
        this.positive_bittape = new ArrayList<Byte>(tape.positive_bittape);
        this.negative_bittape = new ArrayList<Byte>(tape.negative_bittape);
        this.default_state = tape.default_state;
    }

    boolean read(int index) {
        /*
            Returns the value of a bit at a requested index.
        */
        if ((index < 0 && abs(index) - 1 < this.negsize()) || (index >= 0 && index < this.possize())) {
            if (index >= 0) return ((this.positive_bittape.get((index - (index %8))/8)) >> (7 - (index % 8) )& 1) != 0;
            else {
                int true_index = abs(index) - 1;
                return ((this.negative_bittape.get((true_index - (true_index % 8))/8) >> (true_index % 8)) & 1) != 0;
            }
        }
        else return this.default_state;
    }

    void flip(int index) {
        /*
            Inverts a bit at a given index, this used to be a
            much larger function but it now just directs to write
        */
        this.write(index, !this.read(index));
    }

    void write(int index, boolean state) {
        /*
            If the state is the same as the state at the indexed bit,
            just return.
        */
        if (!(this.read(index) ^ state)) return;
        /*
            Write the given state to the bit at the index given.
        */
        if (index >= 0) {
            /*
                Positive bittape is being written to
            */
            /*
                Resize the tape if needed
            */
            while (index >= this.possize()) {
                this.positive_bittape.add(this.default_state ? (byte)0xFF : (byte)0x00);
            }
            /*
                Write to positive bittape
            */
            //Fetch the byte we are working with
            byte wrk_byte = this.positive_bittape.get((index - (index % 8))/8);
            //Set a bit as true and shift it to the mod'ed index position
            byte lgc_byte = (byte)(1 << 7 - (index % 8));
            //Perform an XOR operation between both bytes, flipping the bit that was indexed
            this.positive_bittape.set((index - (index%8))/8, (byte)(lgc_byte ^ wrk_byte));
        }
        else {
            /*
                Negative bittape is being written to
            */
            /*
                Resize the tape if needed
            */
            int wrk_index = (abs(index) - 1);
            while (wrk_index >= this.negsize()) {
                this.negative_bittape.add(this.default_state ? (byte)0xFF : (byte)0x00);
            }
            /*
                Write to negative bittape
            */
            byte wrk_byte = this.negative_bittape.get((wrk_index - (wrk_index % 8))/8);
            //Set a bit as true and shift it to the mod'ed index position
            byte lgc_byte = (byte)(1 << (wrk_index % 8));
            //Perform an XOR operation between both bytes, flipping the bit that was indexed
            this.negative_bittape.set((wrk_index - (wrk_index%8))/8, (byte)(lgc_byte ^ wrk_byte));
        }
    }

    int size() {
        return (positive_bittape.size() + negative_bittape.size()) * 8;
    }
    int possize() {
        return positive_bittape.size() * 8;
    }

    int negsize() {
        return negative_bittape.size() * 8;
    }
}
