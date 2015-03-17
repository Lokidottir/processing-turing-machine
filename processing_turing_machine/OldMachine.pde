/*
    ALERT:
    this class isn't relevent to the current program, and is only kept
    for visibility's sake.
*/

final int TURING_CALLSTACK_LIMIT = (int)pow(2,21);

//Super low registry limit to encourage not overusing the registry >:L
final int TURING_REGISTRY_LIMIT = 32;

class TuringMachine {

    Program program;
    Tape tape;
    int tape_index;
    ArrayList<PageState> page_states;
    ArrayList<Boolean> index_register;
    boolean halted;
    int scan_count;
    boolean in_motion;

    TuringMachine() {
        this.program = new Program();
        this.tape = new Tape();
        this.tape_index = 0;
        this.page_states = new ArrayList<PageState>(1);
        this.index_register = new ArrayList<Boolean>();
        this.halted = false;
        this.scan_count = 0;
        this.in_motion = false;
    }

    TuringMachine(boolean[] tape_init) {
        this();
        this.tape = new Tape(tape_init);
    }

    TuringMachine(Program program) {
        this();
        this.program = new Program(program);
        println("(turing machine) attempting to set initial page value");
        this.page_states.add(new PageState());
        /*
            This has strange behaviour if tampered with.
        */
        this.page_states.get(0).page = program.get(0);
    }

    TuringMachine(final TuringMachine machine) {
        this();
        this.program = new Program(machine.program);
        this.tape = new Tape(machine.tape);
        this.tape_index = machine.tape_index;
        this.page_states = new ArrayList<PageState>(machine.page_states);
        this.index_register = new ArrayList<Boolean>(machine.index_register);
        this.halted = machine.halted;

    }

    void step() {
        /*
            If the machine is halted, simply return
        */
        if (this.halted || this.page_states.size() == 0) return;
        else {
            boolean diff_frame = false;
            PageState state = this.page_states.get(this.page_states.size() - 1);
            Statement statement = (state.statement_index < state.page.statements.size()) ? state.page.statements.get(state.statement_index) : new Statement();
            if (!(state.statement_index < state.page.statements.size())) {
                /*
                    If the statement we have is out of bounds then we need
                    to exit this page and go back to the previous frame, as
                    this page has finished
                */
                if (this.page_states.size() > 0) {
                    this.page_states.remove(this.page_states.size() - 1);
                    this.step();
                }
                else {
                    /*
                        We have reached the end of the program and must halt.
                    */
                    this.halted = true;
                    println("(turing machine) end of program, halted.");
                }
            }
            else {
                //println("(exec@tm) " + typeAsString(statement.instruction));
                switch(statement.instruction) {
                    case SCAN:
                        if (this.in_motion) {
                            /*
                                Move one lef or right, depending. then move scan_count
                                closer to 0.
                            */
                            this.tape_index += this.scan_count/abs(this.scan_count);
                            this.scan_count += -this.scan_count/abs(this.scan_count);
                            /*
                                Scan the statement index back one so that we will still execute
                                as scan next
                            */
                            if (this.scan_count != 0) state.statement_index--;
                            else this.in_motion = false;
                        }
                        else if (statement.arg != 0) {
                            this.in_motion = true;
                            this.scan_count = statement.arg - (statement.arg/abs(statement.arg));
                            this.tape_index += this.scan_count != 0 ? this.scan_count/abs(this.scan_count) : statement.arg;
                            if (this.scan_count != 0) state.statement_index--;
                            else this.in_motion = false;
                        }
                        break;
                    case CALL:
                        if (this.page_states.size() < TURING_CALLSTACK_LIMIT) {
                            PageState new_state = new PageState();
                            new_state.statement_index = 0;
                            new_state.page = this.program.get(statement.arg);
                            this.page_states.add(new_state);
                        }
                        else {
                            println("(turing machine) call stack limit (" + TURING_CALLSTACK_LIMIT + ") reached, halting program.");
                            this.halted = true;
                        }
                        break;
                    case FLIP:
                        this.tape.flip(this.tape_index);
                        break;
                    case IFBIT:
                        if (!this.tape.read(this.tape_index)) {
                            /*
                                Scan to the next matching ENDIF statement
                            */
                            int depth = 0;
                            int close_index;
                            /*
                                For-matted (ha) for loop as this has a bunch of conditions
                            */
                            for (close_index = state.statement_index + 1;
                                /*
                                    First we set the close_index variable as the next index.
                                    The conditions are the following: if the statement at the
                                    index of close_index is not an ENDIF statement, or the depth
                                    is greater than 0, then the loop continues, and close_index
                                    is incremented.
                                    There is also the condition that close_index is within the bounds
                                    of the statement list.
                                */
                                (state.page.statements.get(close_index).instruction != Instruction.ENDIF
                                || depth > 0)
                                && close_index < state.page.statements.size();
                                close_index++) {
                                /*
                                    If the instruction is an IFBIT statement then we need to increase
                                    the depth for the nested conditionals.
                                    If it's an ENDIF statement then we need to decrement the depth.
                                */
                                if (state.page.statements.get(close_index).instruction == Instruction.IFBIT) depth++;
                                else if (state.page.statements.get(close_index).instruction == Instruction.ENDIF) depth--;
                            }
                            /*
                                The closing index is found, assign it as the new index.
                            */
                            state.statement_index = close_index;
                        }
                        /*
                            Otherwise just proceed with the rest of the statements.
                        */
                        break;
                    case ENDIF:
                        /*
                            Just skip
                        */
                        break;
                    case HALT:
                        /*
                            The program halts
                        */
                        this.halted = true;
                        break;
                    case SAVE:
                        /*
                            Save the current bit on the stack
                        */
                        if (this.index_register.size() < TURING_REGISTRY_LIMIT) {
                            this.index_register.add(this.tape.read(this.tape_index));
                        }
                        else {
                            println("(turing machine) error: registry size limit (" + TURING_REGISTRY_LIMIT + ") reached, halting program.");
                            this.halted = true;
                        }
                        break;
                    case SPOP:
                        /*
                            Pop the top item on the index
                        */
                        if (this.index_register.size() > 0) {
                            this.index_register.remove(this.index_register.size() - 1);
                        }
                        else {
                            println("(turing machine) error: cannot pop any more indexes from the register, halting program");
                            this.halted = true;
                        }
                        break;
                    case LGIC:
                        /*
                            Apply a logical operation to the current bit with a
                            registry-saved bit
                        */
                        //println("(turing machine) " + (int)(statement.arg & 0xFFFF) + " from " + Integer.toBinaryString(statement.arg));
                        //print("(turing machine) making a ");
                        int reg_index = this.index_register.size() - ((statement.arg >> 16) + 1);
                        switch(Logical.values()[(int)(statement.arg & 0xFFFF)]) {
                            case AND:
                                //print("and");
                                this.tape.write(this.tape_index, (this.tape.read(this.tape_index) && this.index_register.get(reg_index).booleanValue()));
                                break;
                            case OR:
                                //print("or");
                                this.tape.write(this.tape_index, (this.tape.read(this.tape_index) || this.index_register.get(reg_index).booleanValue()));
                                break;
                            case XOR:
                                //print("xor");
                                this.tape.write(this.tape_index, (this.tape.read(this.tape_index) ^ this.index_register.get(reg_index).booleanValue()));
                                break;
                            case NOT:
                                //print("not");
                                this.tape.write(this.tape_index, !this.index_register.get(reg_index).booleanValue());
                                break;
                            default:
                                print("(turing machine) could not understand logical instruction type, halting program.");
                                this.halted = true;
                                break;
                        }
                        //println(" statement at index " + reg_index);
                        break;
                    case NONE:
                        /*
                            Just skip
                        */
                        break;
                    default:
                        println("(turing machine) instruction not implemented");
                        break;
                }
                state.statement_index++;
            }
        }
    }

    Instruction currentInstruction(int offset) {
        if (this.page_states.size() > 0) {
            PageState state = this.page_states.get(this.page_states.size() - 1);
            Statement statement = (state.statement_index < state.page.statements.size()) ? state.page.statements.get(state.statement_index) : state.page.statements.get(state.page.statements.size() - 1);
            return statement.instruction;
        }
        else return Instruction.HALT;
    }

    Instruction currentInstruction() {
        return this.currentInstruction(0);
    }

    void step(int exec_num) {
        /*
            Perform "exec_num" steps
        */
        for (int i = 0; i < exec_num && !this.halted; i++) {
            this.step();
        }
    }
}

class PageState {
    /*
        Pagestate class for folding stack frame data
    */
    int statement_index;
    Page page;

    PageState() {

    }

    PageState(Page page) {
        this.page = new Page(page);
        this.statement_index = 0;
    }
}
