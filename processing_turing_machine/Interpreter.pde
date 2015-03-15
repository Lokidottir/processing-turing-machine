import java.lang.Integer;

final String ITSK_REGEX = "(\\S{4,5})";
final String IARG_REGEX = "(\\S+)";
final String ICMT_REGEX = "(\\/\\/.+)";
final String INUM_REGEX = "(@[0-9]+)";
final String IMAC_REGEX = "((\\d+\\s*\\|\\s*){5}\\d+.*)";
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
        String wrk_src = this.source.replaceAll(ICMT_REGEX,"");              //Remove all comments from the source code
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
        if (firstMatch("((false)|(true))",if_str).equals("true")) {
            /*
                the if section is dependent on the bit that the head of the
                turing machine is 1/true etc.
            */
            state.if_true  = this.parseDecision(if_str, state.statenum);
            state.if_false = this.parseDecision(else_str, state.statenum);
        }
        else if (firstMatch("((false)|(true))",if_str).equals("false")) {
            /*
                the if section is inverted, the if section only runs if the
                bit at the head of the turing machine is false.
            */
            state.if_true  = this.parseDecision(else_str, state.statenum);
            state.if_false = this.parseDecision(if_str, state.statenum);
        }
        else {
            /*
                undefined case, return null as parsing wasn't successful.
            */
            println("[TMParser.parseState] ");
            return null;
        }
        if (state.if_true == null || state.if_false == null) {
            /*
                if either of the decisions are null, return null as the
                parsing has failed.
            */
            return null;
        }
        return state;
    }

    TMDecision parseDecision(String decision_string, int statenum) {
        /*
            Parse a decision (write/move/goto statement) from a string
            describing the decision.
        */
        TMDecision decision = new TMDecision();
        String write_section = firstMatch("(write\\s+[01]|(true)|(false))", decision_string);
        if (write_section.equals("")) {
            /*
                The write section isn't defined, so define it as
            */
            decision.write_tape = -1; //-1 denotes "don't write anything to this"
        }
        else {
            try {

            }
            catch (NumberFormatException err) {

            }
        }
        String move_section = firstMatch("(move\\s+[0-9]+)", decision_string);
        String goto_section = firstMatch("(goto.+)", decision_string);
        return decision;
    }
}

class TMDecision {
    int write_tape; //Ommitable as keep current
    int move_head;  //Ommitable as stay at position
    int goto_state; //Ommitable as go to the next (+1) state

    TMDecision() {

    }

    TMDecision(int write_tape, int move_head, int goto_state) {
        this.write_tape = write_tape;
        this.move_head = move_head;
        this.goto_state = goto_state;
    }
}

class TMState {
    String source;
    int statenum;
    TMDecision if_true;
    TMDecision if_false;

    TMState() {
        this.if_false = new TMDecision();
        this.if_true = new TMDecision();
    }
}

class TMProgram {
    String source;
    ArrayList<TMState> states;

    TMProgram() {
        this.states = new ArrayList<TMState>();
    }
}
