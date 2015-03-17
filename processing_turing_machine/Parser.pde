/*
    Fionan Haralddottir
    Turing Machine in Processing
    March 2015
*/

import java.lang.Integer;
final String ICMT_REGEX = "(\\/\\/.+)";
final String INUM_REGEX = "(@[0-9]+)";
final String IMCS_REGEX = //The regex that matches a sub-part of the compact code
                            "([\\+\\-])?(d+))";
final String IHUM_REGEX = //The regex that matches the whole human-readable state
                            "((@[0-9]+))[^@]*(?=endif)(endif)";
final String IIFB_REGEX = //The regex that matches the if portion of the readable mode state
                            "((if)[\\S\\s]*(?=else))";
final String IELS_REGEX = //The regex that matches the else portion of the readable mode state
                            "((else)[\\S\\s]*(?=endif))";



class TMParser {
    String source;

    TMParser(String source) {
        this.source = source; //set the source as the given string
    }

    TMProgram parse(String source) {
        String tmp_str = this.source;       //Set a temporary variable to hold the current source
        this.source = source;               //Set the object's source as the source code parameter
        TMProgram program = this.parse();   //Parse the code and hold the program in a variable
        this.source = tmp_str;              //Reset the original string as the object's source feild
        return program;
    }

    TMProgram parse() {
        /*
            Parse a turing machine from the turing machine
            description in the provided string
        */
        TMProgram program = new TMProgram();
        String wrk_src = this.source.replaceAll(ICMT_REGEX,""                //Remove all comments from the string
                                   ).replaceAll("(false)","0"                //Replace all instances of "false" with "0"
                                   ).replaceAll("(true)","1"                 //Replace all instances of "true" with "1"
                                   ).replaceAll("(halt)",                    //Replace all instances of "halt" with the maximum integer value
                                                         Integer.toString(HALTED_STATENUM));

        ArrayList<String> all_states = allRegexMatches(IHUM_REGEX,wrk_src);  //Find all strings that match the state regex
        println("found " + all_states.size() + " states");                   //emit how many states were found
        for (int state_index = 0; state_index < all_states.size(); state_index++) {
            /*
                Loop through the strings that matched the regular expression
                designed to match a state of the turing machine, call a function
                that parses these strings into TMState objects.
            */
            println("[TMParser.parse -> .parseState] parsing state " + (state_index + 1) + " of " + all_states.size());  //emit state x of n, not state number.
            TMState parsed_state = this.parseState(all_states.get(state_index));
            if (parsed_state == null) {
                /*
                    An error occured and the state could not be parsed correctly,
                    null is returned.
                */
                println("[TMParser.parse] Failed to parse state from code: " + all_states.get(state_index));
                return null;
            }
            program.states.add(parsed_state); //Add the evaluated state to the program's list of states.
        }
        println("[TMParser.parse] returning parsed program");
        return program;
    }

    TMState parseState(String state_string) {
        /*
            Parse a State of the turing machine from a string
            describing the state.
        */
        TMState state = new TMState();

        /*
            Get the first match for a state number string from the
            state string provided, then parse an integer from the
            substring of that from index 1, as the first character is
            a "@" which is ignored.
        */
        state.statenum = Integer.parseInt(firstMatch(INUM_REGEX,state_string).substring(1));

        String if_str   = firstMatch(IIFB_REGEX, state_string); //Get the string that represents the if section of the state
        String else_str = firstMatch(IELS_REGEX, state_string); //Get the string that represents the else section of the state
        println("[TMParser.parseState -> .parseDecision] parsing decisions");
        if (firstMatch("([01])",if_str).equals("1")) {
            /*
                the if section is dependent on the bit that the head of the
                turing machine is 1/true etc.
            */
            state.if_true  = this.parseDecision(if_str, state.statenum);
            state.if_false = this.parseDecision(else_str, state.statenum);
        }
        else if (firstMatch("([01])",if_str).equals("0")) {
            /*
                the if section is inverted, the if section only runs if the
                bit at the head of the turing machine is 0/false.
            */
            state.if_true  = this.parseDecision(else_str, state.statenum);
            state.if_false = this.parseDecision(if_str, state.statenum);
        }
        else {
            /*
                undefined case, return null as parsing wasn't successful.
            */
            println("[TMParser.parseState][Err] could not parse if decision from code:\n\t" + state_string);
            return null;
        }
        if (state.if_true == null || state.if_false == null) {
            /*
                if either of the decisions are null, return null as the
                parsing has failed.
            */
            return null;
        }
        println("[TMParser.parseState] returning parsed state");
        return state;
    }

    TMDecision parseDecision(String decision_string, int statenum) {
        /*
            Parse a decision (write/move/goto statement) from a string
            describing the decision.
        */
        TMDecision decision = new TMDecision();
        String write_section = firstMatch("(write\\s+[01])", decision_string);
        println("[TMParser.parseDecision] parsing write section");
        if (write_section.equals("")) {
            /*
                The write section isn't defined, so define it as keeping
                the tape as it is
            */
            println("[TMParser.parseDecision] no write provided, interpreting as keep (-1)");
            decision.write_tape = -1; // n < 0 denotes "don't write anything to this"
        }
        else {
            try {
                /*
                    Parse the argument for "write" as an integer (n == 0 as write 0,
                    n == 1 as write 1).
                */
                decision.write_tape = Integer.parseInt(firstMatch("([01])",write_section));
                println("[TMParser.parseDecision] parsed write argument as " + decision.write_tape);
            }
            catch (NumberFormatException err) {
                /*
                    Parse error, return null
                */
                println("[TMParser.parseDecision][Err] Could not parse write argument from code:\n\t" + write_section);
                return null;
            }
        }
        String move_section = firstMatch("(move\\s+[+-]?[0-9]+)", decision_string);
        println("[TMParser.parseDecision] parsing move section");
        if (move_section.equals("")) {
            /*
                The move section is ommited, so define it as stay.
            */
            decision.move_head = 0; //Move no number of tape segments
            println("[TMParser.parseDecision] no move provided, interpreting as stay (0)");
        }
        else {
            try {
                /*
                    Parse the argument for "move" as an integer (n < 0 as n
                    segments left, n > 0 as n segments right, n == 0 as stay).
                */
                decision.move_head = Integer.parseInt(firstMatch("(([\\+\\-]){0,1}[0-9]+)",move_section));
                println("[TMParser.parseDecision] parsed move argument as " + decision.move_head);

            }
            catch (NumberFormatException err) {
                /*
                    Parse error, return null.
                */
                println("[TMParser.parseDecision][Err] Could not parse move argument from code:\n\t" + move_section);
                return null;
            }
        }
        String goto_section = firstMatch("(goto.+)", decision_string);
        println("[TMParser.parseDecision] parsing goto section");
        if (goto_section.equals("")) {
            /*
                The goto section is ommited, so define it as goto + 1.
            */
            decision.goto_state = statenum + 1; //Go to the next state
            println("[TMParser.parseDecision] no goto provided, interpreting as goto next state (+1)");
        }
        else {
            try {
                /*
                    Parse the argument for "goto" as an integer, first looking for
                    a sign to indicate if the movement is relative or not.

                    if there is a sign (+/-) then the state is added to the statenum
                    variable, as the goto is relative, otherwise it is absolute and is
                    set as the goto_state field.
                */
                if (firstMatch("([\\+\\-])",goto_section).equals("")) {
                    /*
                        There's no sign on the goto, it is absolute.
                    */
                    decision.goto_state = Integer.parseInt(firstMatch("([0-9]+)",goto_section));
                }
                else {
                    /*
                        The goto is signed, and is therefore relative. adding the statenum
                        to the relative value gets the absolute next state.
                    */
                    decision.goto_state = statenum + Integer.parseInt(firstMatch("([0-9]+)",goto_section));
                }
                println("[TMParser.parseDecision] parsed goto argument as " + decision.goto_state);

            }
            catch (NumberFormatException err) {
                /*
                    Parse error, return null.
                */
                println("[TMParser.parseDecision][Err] Could not parse goto argument from code:\n\t" + goto_section);
                return null;
            }
        }
        println("[TMParser.parseDecision] returning parsed decision");
        return decision;
    }
}

class TMDecision {
    /*
        Decision class, represents the write -> move -> goto
        operations of a decision (if/else) in a state.
    */
    int write_tape; //Ommitable as keep current
    int move_head;  //Ommitable as stay at position
    int goto_state; //Ommitable as go to the next (+1) state

    TMDecision() {

    }
}

class TMState {
    /*
        State class, represents a single state holding two
        decisions, the state number and the if/else decisions.
    */
    int statenum;
    TMDecision if_true;
    TMDecision if_false;

    TMDecision getDecisionByBoolean(boolean decision_bool) {
        return (decision_bool ? if_true : if_false);
    }

    TMState() {
        this.if_false = new TMDecision();
        this.if_true = new TMDecision();
    }
}

class TMProgram {
    /*
        Program class, represents a set of states that are
        executed by the Turing machine as a program.
    */
    ArrayList<TMState> states; //An array of states representing the

    TMState getStateByStatenum(int statenum) {
        /*
            Returns the state that has the state number specified or null
            if that state does not exist.
        */
        for (int i = 0; i < this.states.size(); i++) {
            if (this.states.get(i).statenum == statenum) return this.states.get(i);
        }
        return null;
    }

    TMProgram() {
        this.states = new ArrayList<TMState>();
    }
}
