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
float actions_per_second = 5;

void setup() {
    rectMode(CENTER);
    size((int)(displayWidth * 0.925), (int)(displayHeight * 0.925));
    frame.setTitle("Turing Machine Emulator and Editor in Processing");
    clock = new Clock();
    TMProgram program = (new TMParser(loadFileAsString(dataPath("example-programs/busy_beaver.tmc")))).parse();
    TMachine turing_machine = new TMachine(program);
    turing_machine_renderer = new TMRenderer(turing_machine,
                                             actions_per_second,
                                             width/2,
                                             height/2,
                                             width,
                                             16);
    //turing_machine.halted = true;
    editor = new TextEditor();
    editor.loadProgram(dataPath("example-programs/busy_beaver.tmc")); //load example program
    editor.current_file_location = null;                              //disallow oversaving the example program
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

void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {
    editor.handleTextEvents(textcontrol,event);
}

void handleButtonEvents(GButton button, GEvent event) {
    editor.handleButtonEvents(button,event);
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
