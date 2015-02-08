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

class TMInterpreter {

}

class InterpretedProgram {
    int row_index;
    int col_index;
}
