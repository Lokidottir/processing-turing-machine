/*
    Fionan Haralddottir
    Turing Machine in Processing
    March 2015
*/

/*
    Messy code for text editor /here/ so that code is cleaner in
    other places. I apologise for many things here.
*/

import java.awt.Font;

class TextEditor {
    GTextArea text_area;          //The text area object being wrapped
    String current_file_location; //The file location of the file being edited
    float toggle_width;           //The toggle width of the
    GButton save_button;          //The saveing button
    GButton run_button;           //The program run button
    GButton toggled_paused_button;//The program pause button
    GButton save_as_button;        //The resume program button
    GButton reset_button;         //The program clear tape button
    GButton load_button;          //The load program from file button
    TextEditor() {
        this.text_area = setupNewTextArea(width * 0.8,                                    //x-coordinate of the text area
                                          0,                                              //y-coordinate of the text area
                                          width * 0.2,                                    //width of the text area
                                          height - 60,                                    //height of the text area
                                          G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE); //have scrollbars that autohide
        this.text_area.setText("//Paste/load/write code here");
        this.text_area.setFont(FontManager.getFont("Courier 10 Pitch",Font.PLAIN,15));
        this.save_button = setupNewButton(this.text_area.getX(),                                    //Set up the save button
                                          this.text_area.getY() + this.text_area.getHeight(),
                                          this.text_area.getWidth()/2,
                                          20,
                                          "save");
        this.load_button = setupNewButton(this.text_area.getX() + this.text_area.getWidth()/2,      //Set up the Load button
                                          this.text_area.getY() + this.text_area.getHeight(),
                                          this.text_area.getWidth()/2,
                                          20,
                                          "load");
        this.toggled_paused_button = setupNewButton(
                                           this.text_area.getX() + this.text_area.getWidth()/2,    //Set up the resume button
                                           this.text_area.getY() + this.text_area.getHeight() + 20,
                                           this.text_area.getWidth()/2,
                                           20,
                                          "pause/play");
        this.save_as_button = setupNewButton(this.text_area.getX(),                                 //Set up the save as button
                                            this.text_area.getY() + this.text_area.getHeight() + 20,
                                            this.text_area.getWidth()/2,
                                            20,
                                            "save as");
        this.reset_button = setupNewButton(this.text_area.getX(),                                   //Set up the reset button
                                          this.text_area.getY() + this.text_area.getHeight() + 40,
                                          this.text_area.getWidth()/2,
                                          20,
                                          "reset machine");
        this.run_button =  setupNewButton(this.text_area.getX() + this.text_area.getWidth()/2,      //Set up the run button
                                          this.text_area.getY() + this.text_area.getHeight() + 40,
                                          this.text_area.getWidth()/2,
                                          20,
                                          "compile program");


        this.toggle_width = 20;
    }

    void handleButtonEvents(GButton button, GEvent event) {
        if (event == GEvent.CLICKED) {
            if (button == this.save_button) {
                if (this.current_file_location != null) {
                    this.saveCurrentProgram();
                }
                else {
                    selectOutput("Select where you want to save the program", "saveFileFromPrompt");
                }
            }
            else if (button == this.load_button)  {
                selectInput("Select a file to load into the text editor.", "loadProgramFromPrompt");
            }
            else if (button == this.toggled_paused_button) {
                turing_machine_renderer.togglePaused();
            }
            else if (button == this.save_as_button) {
                selectOutput("Select where you want to save the program", "saveFileFromPrompt");
            }
            else if (button == this.reset_button) {
                turing_machine_renderer.reset();
            }
            else if (button == this.run_button) {
                print("!!!");
                turing_machine_renderer.reset((new TMParser(knitStringArray(this.text_area.getTextAsArray(), "\n")).parse()));
            }
        }
    }

    void saveCurrentProgram() {
        saveStrings(dataPath(this.current_file_location),this.text_area.getTextAsArray());
    }

    void loadProgram(String path) {
        this.current_file_location = path;
        this.text_area.setText(loadStrings(path));
    }

    void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {

    }

    void mousePressed(float x, float y) {
        if (this.withinToggleBounds(x,y)) {
            if (this.text_area.isVisible()) {
                this.text_area.setVisible(false);
                this.save_button.setVisible(false);
                this.run_button.setVisible(false);
                this.toggled_paused_button.setVisible(false);
                this.save_as_button.setVisible(false);
                this.reset_button.setVisible(false);
                this.load_button.setVisible(false);
            }
            else {
                this.text_area.setVisible(true);
                this.save_button.setVisible(true);
                this.run_button.setVisible(true);
                this.toggled_paused_button.setVisible(true);
                this.save_as_button.setVisible(true);
                this.reset_button.setVisible(true);
                this.load_button.setVisible(true);
            }
        }
        turing_machine_renderer.display_width = (width - this.fullWidth());
        turing_machine_renderer.x = turing_machine_renderer.display_width/2;
    }

    boolean withinToggleBounds(float x, float y) {
        return x >= width - this.fullWidth() && x < width - (this.fullWidth() - this.toggle_width);
    }

    float fullWidth() {
        if (this.text_area.isVisible()) {
            return this.toggle_width + this.text_area.getWidth();
        }
        else return this.toggle_width;
    }

    void displayToggler() {
        rectMode(CORNER);
        stroke(227,230,255);
        fill(227,230,255);
        rect(width - this.fullWidth(), this.text_area.getY(), this.toggle_width, height);
    }
}

GTextArea setupNewTextArea(float x, float y, float width, float height, int policies) {
    return new GTextArea(this,x,y,width,height,policies);
}

GButton setupNewButton(float x, float y, float width, float height, String text) {
    return new GButton(this,x,y,width,height,text);
}

void loadProgramFromPrompt(File file) {
    if (file == null) return;
    editor.loadProgram(file.toString());
}

void saveFileFromPrompt(File file) {
    if (file == null) return;
    editor.current_file_location = file.toString();
    editor.saveCurrentProgram();
}
