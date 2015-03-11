/*
final String TSK_REGEX = "(([a-zA-Z]{3})([^\\n]*))";
final String ARG_REGEX = "(\\S+)";
final String WSP_REGEX = "((\\ |\\t))";
final String CMT_REGEX = "(\\/\\/.+)";
final String PGE_REGEX = "((\\[PAGE [0-9]{1,3}\\])(?<=\\[PAGE [0-9]{1,3}\\])([^\\[\\]])+(?=\\[ENDPAGE\\])(\\[ENDPAGE\\]))";
*/

final String ITSK_REGEX = "(\\S{4,5})";
final String IARG_REGEX = "(\\S+)";
final String ICMT_REGEX = "(\\/\\/.+)";
final String INUM_REGEX = "(\\@[0-9]+)";
final String IMAC_REGEX = "((\\s+(d+)\\s+\\|){5}(\\d+))";
final String IHUM_REGEX = "(" + INUM_REGEX + "(?=endif)(endif))";
final String IIFB_REGEX = "((if)(?=else))";
final String IELS_REGEX = "()";

class TMInterpreter {
    String source;

    TMInterpreter(String source) {
        this.source = source;
    }

    TMProgram assemble() {
        String wrk_src = this.source.replaceAll(ICMT_REGEX,"//");
        String mode = firstMatch("((mode)|(MODE).+)", wrk_src);
        if (!firstMatch("(readable)", mode).equals("")) {
            /*
                The mode of the program is human-readable.
            */

        }
        else {
            /*
                The mode of the program is compact.
            */
        }
    }
}

class TMDecision {
    String source;
    int write_tape; //Ommitable as keep current
    int move_head;  //Ommitable as stay at position
    int goto_state; //Ommitable as go to the next (+1) state
}

class TMState {
    String source;
    int statenum;
    TMDecision if_true;
    TMDecision if_false;
}

class TMProgram {
    String source;
    ArrayList<TMState> states;
}
