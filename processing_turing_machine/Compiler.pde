/*
    Compiler related classes and functions, converts an assembly-like language
    to a series of symbols that represent the implied commands.
*/

final String TSK_REGEX = "(([a-zA-Z]{3})([^\\n]*))";
final String ARG_REGEX = "(\\S+)";
final String WSP_REGEX = "((\\ |\\t))";
final String CMT_REGEX = "(\\/\\/.+)";
final String PGE_REGEX = "((\\[PAGE [0-9]{1,3}\\])(?<=\\[PAGE [0-9]{1,3}\\])([^\\[\\]])+(?=\\[ENDPAGE\\])(\\[ENDPAGE\\]))";

class TMCompiler {
    String source;

    TMCompiler(final String source) {
        this.source = new String(source);
    }

    Program compile() {
        /*
            Split to pages
        */
        println("(compiler) program compilation requested");
        println("(compiler) stripping comments");
        /*
            Find and strip all comments.
        */
        this.source = this.source.replaceAll(CMT_REGEX,"");
        println("(compiler) compiling written machine code");
        /*
            Split the source code into pages
        */
        Program program = new Program();
        ArrayList<String> pages = allRegexMatches(PGE_REGEX,this.source);
        println("(compiler) found " + pages.size() + " pages to read");
        for (int i = 0; i < pages.size(); i++) {
            /*
                Compile each page seperately
            */
            println("(compiler) compiling page " + (i+1) + " of " + pages.size());
            println(pages.get(i));
            program.pages.add(this.compilePage(pages.get(i)));
        }
        program.sort();
        println("(compiler) Program successfully compiled.");
        return program;
    }

    ArrayList<String> getStatements(final String page_str) {
        String wrk_page = page_str.replaceAll("(\\[[a-zA-Z0-9\\s]+\\])", "");
        return allRegexMatches(TSK_REGEX, wrk_page);
    }

    Page compilePage(final String source) {
        /*
            Split to statements.
        */
        Page page = new Page();
        println("(page) compiling page...");
        try {
            page.pagenum = Integer.parseInt(firstMatch("([0-9]{1,3})",source));
        }
        catch (NumberFormatException err) {
            println("(page) could not read page number! please check your source code.");
            println("(page) error from: " + source);
        }
        println("(page) page number evaluated as: " + page.pagenum);
        ArrayList<String> statements = this.getStatements(source);
        /*
            Skip the first and last elements, as those are just page declartions
        */
        println("(page) found " + statements.size() + " statements in page");
        for (int i = 0; i < statements.size(); i++) {
            println("(page) statement " + i + " is " + statements.get(i));
        }
        for (int i = 0; i < statements.size(); i++) {
            println("(page) compiling statement " + i + " of " + (statements.size() - 1));
            page.statements.add(this.compileStatement(statements.get(i)));
        }
        return page;
    }

    Statement compileStatement(final String source) {
        /*
            Finally evaluate as single statements
        */
        Statement statement = new Statement();
        /*
            Split the line into non-whitespace parts.
        */
        ArrayList<String> split_line = allRegexMatches(ARG_REGEX, source);
        println("(statement) found " + split_line.size() + " elements in the statement");
        println("(statement) Deduceing type");
        /*
            Get instruction type from first argument
        */
        statement.instruction = instructionType(split_line.get(0));
        println("(statement) instruction type deduced to: " + typeAsString(statement.instruction));
        if (statement.instruction == Instruction.NONE) {
            println("(statement) could not deduce instruction type! please check your source code.");
            println("(statement) error from: " + split_line.get(0));
        }
        else switch(statement.instruction) {
            case SCAN:
            case CALL:
                try {
                    statement.arg = Integer.parseInt(split_line.get(1));
                }
                catch (NumberFormatException err) {
                    println("(statement) could not parse integer for SCAN/CALL argument! please check your source code.");
                    println("(statement) error from: " + split_line.get(1));
                }
                catch (IndexOutOfBoundsException err) {
                    println("(statement) could not parse SCAN/CALL arguments, have you supplied them? please check your source code.");
                    println("(statement) error from: " + source);
                }
                break;
            case LGIC:
                //first 16 bits contain the operator type, second 16 bits contain the register stack index
                try {
                    statement.arg = ((int(Integer.parseInt(firstMatch("(\\#[0-9]+)",split_line.get(2)).substring(1)) << 16) | int(logicalType(split_line.get(1)).ordinal())));
                    if ((statement.arg & 0xFFFF) == Logical.NONE.ordinal()) {
                       println("(statement) could not deduce logical operator! please check your source code.");
                       println("(statement) error from: " + split_line.get(1));
                    }
                }
                catch (NumberFormatException err) {
                    println("(statement) could not parse registry index! please check your source code.");
                    println("(statement) error from: " + split_line.get(2));
                }
                catch (IndexOutOfBoundsException err) {
                    println("(statement) could not parse logic arguments, have you supplied them? please check your source code.");
                    println("(statement) error from: " + source);
                }
                break;
            default: break;
        }
        return statement;
    }
}

class Statement {
    Instruction instruction;
    int arg;

    Statement() {
        this.instruction = Instruction.HALT;
        this.arg = 0;
    }

    Statement(final Statement statement) {
        println("(copy) copying statement");
        this.instruction = statement.instruction;
        this.arg = statement.arg;
    }

}

class Page {
    ArrayList<Statement> statements;
    int pagenum;

    Page() {
        this.statements = new ArrayList<Statement>();
        this.pagenum = -1;
    }

    Page(final Page page) {
        println("(copy) copying page");
        this.statements = new ArrayList<Statement>(page.statements);
        this.pagenum = page.pagenum;
    }

    int compareTo(final Page page) {
        return (this.pagenum - page.pagenum);
    }
}

class Program {
    ArrayList<Page> pages;

    Program() {
        this.pages = new ArrayList<Page>();
    }

    Program(final Program program) {
        println("(copy) copying program");
        this.pages = new ArrayList<Page>(program.pages);
    }

    void sort() {
        /*
            Bubble sort pages, in case the pages were declared out of order
        */
        boolean bubbled_flag = true;
        for (int i = 1; i < this.pages.size() && bubbled_flag; i++) {
            bubbled_flag = false;
            for (int j = 0; j < this.pages.size() - i; j++) {
                if (this.pages.get(j).pagenum > this.pages.get(j+1).pagenum) {
                    int temp = this.pages.get(j).pagenum;
                    this.pages.get(j).pagenum = this.pages.get(j+1).pagenum;
                    this.pages.get(j+1).pagenum = temp;
                    bubbled_flag = true;
                }
            }
        }
        for (int i = 0; i < this.pages.size(); i++) {
            println("(program) page " + this.pages.get(i).pagenum + " at index " + i);
        }
    }

    Page get(int pagenum) {
        for (int i = 0; i <= pagenum && i < this.pages.size(); i++) {
            if (this.pages.get(i).pagenum == pagenum) return pages.get(i);
        }
        return new Page();
    }
}

Instruction instructionType(final String code) {
    String wrk_code = code.toUpperCase();
    if (wrk_code.equals("SCAN")) return Instruction.SCAN;
    if (wrk_code.equals("CALL")) return Instruction.CALL;
    if (wrk_code.equals("FLIP")) return Instruction.FLIP;
    if (wrk_code.equals("IFBIT"))return Instruction.IFBIT;
    if (wrk_code.equals("ENDIF"))return Instruction.ENDIF;
    if (wrk_code.equals("HALT")) return Instruction.HALT;
    if (wrk_code.equals("SAVE")) return Instruction.SAVE;
    if (wrk_code.equals("SPOP")) return Instruction.SPOP;
    if (wrk_code.equals("LGIC")) return Instruction.LGIC;
    else return Instruction.NONE;
}

String typeAsString(Instruction instruction) {
    switch(instruction) {
        case SCAN: return "SCAN";
        case CALL: return "CALL";
        case FLIP: return "FLIP";
        case IFBIT:return "IFBIT";
        case ENDIF:return "ENDIF";
        case HALT: return "HALT";
        case SAVE: return "SAVE";
        case SPOP: return "SPOP";
        case LGIC: return "LGIC";
        default:   return "NONE";
    }
}

Logical logicalType(final String code) {
    String wrk = code.toUpperCase();
    if (wrk.equals("AND")) return Logical.AND;
    if (wrk.equals("OR"))  return Logical.OR;
    if (wrk.equals("XOR")) return Logical.XOR;
    if (wrk.equals("NOT")) return Logical.NOT;
    else return Logical.NONE;
}
