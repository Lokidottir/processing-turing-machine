/*
    Fionan Haralddottir
    Turing Machine in Processing
    March 2015

    If you are running this program in the Processing IDE/processing-java, be sure you
    have G4P installed.
*/

import g4p_controls.*;

TextEditor editor;
String     src_code;
Clock      clock;
TMRenderer turing_machine_renderer;

//Change this variable to change the speed of the turing machine
float actions_per_second = 3;

void setup() {
    rectMode(CENTER);
    size((int)(displayWidth * 0.925), (int)(displayHeight * 0.925));
    clock = new Clock();
    TMProgram program = (new TMParser(loadFileAsString(dataPath("example-programs/busy_beaver.tmc")))).parse();
    TMachine turing_machine = new TMachine(program);
    turing_machine_renderer = new TMRenderer(turing_machine,
                                             actions_per_second,
                                             width/2,
                                             height/2,
                                             width, 15);
    turing_machine.halted = true;
    editor = new TextEditor();
                                             /*
    text_editor = new GTextArea(this,20,20,200,200,G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
    text_editor.setText("//Write/load something here");
    text_editor.setPromptText("Enter or load code into here to run on the turing machine");
*/
}

void printathing() {
    print("athing");
}

void draw() {
    clock.update(1);
    background(255);
    turing_machine_renderer.update(clock);
    turing_machine_renderer.display(clock);
    editor.displayToggler();
    fill(0);
}

void mousePressed () {
    editor.mousePressed(mouseX,mouseY);
}


String loadFileAsString(String path) {
    return knitStringArray(loadStrings(path),"\n");
}

String knitStringArray(String[] str_arr) {
    return knitStringArray(str_arr, "");
}

String knitStringArray(String[] str_arr, String seperator) {
    String str = "";
    for (int i = 0; i < str_arr.length; i++) str += str_arr[i] + seperator;
    return str;
}
