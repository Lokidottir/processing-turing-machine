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
    GButton pause_button;         //The program pause button
    GButton resume_button;        //The resume program button
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
        this.save_button = setupNewButton(this.text_area.getX(),
                                          this.text_area.getY() + this.text_area.getHeight(),
                                          this.text_area.getWidth()/2,
                                          20,
                                          "save file");
        this.load_button = setupNewButton(this.text_area.getX() + this.text_area.getWidth()/2,
                                          this.text_area.getY() + this.text_area.getHeight(),
                                          this.text_area.getWidth()/2,
                                          20,
                                          "load file");
        this.run_button =  setupNewButton(this.text_area.getX() + this.text_area.getWidth()/2,
                                          this.text_area.getY() + this.text_area.getHeight() + 40,
                                          this.text_area.getWidth()/2,
                                          20,
                                          "run program");
        this.pause_button = setupNewButton(this.text_area.getX(),
                                           this.text_area.getY() + this.text_area.getHeight() + 20,
                                           this.text_area.getWidth()/2,
                                           20,
                                          "pause machine");
        this.resume_button = setupNewButton(this.text_area.getX() + this.text_area.getWidth()/2,
                                          this.text_area.getY() + this.text_area.getHeight() + 20,
                                          this.text_area.getWidth()/2,
                                          20,
                                          "resume machine");
        this.reset_button = setupNewButton(this.text_area.getX(),
                                          this.text_area.getY() + this.text_area.getHeight() + 40,
                                          this.text_area.getWidth()/2,
                                          20,
                                          "reset machine");


        this.toggle_width = 20;
    }

    void handleButtonEvents(GButton button, GEvent event) {
        if (button == this.save_button && event == GEvent.CLICKED) {
            this.saveCurrentProgram();
        }
    }

    void saveCurrentProgram() {
        if (this.current_file_location == null) {

        }
    }

    void handleTextEvents() {

    }

    void mousePressed(float x, float y) {
        if (this.withinToggleBounds(x,y)) {
            if (this.text_area.isVisible()) {
                this.text_area.setVisible(false);
                this.save_button.setVisible(false);
                this.run_button.setVisible(false);
                this.pause_button.setVisible(false);
                this.resume_button.setVisible(false);
                this.reset_button.setVisible(false);
                this.load_button.setVisible(false);
            }
            else {
                this.text_area.setVisible(true);
                this.save_button.setVisible(true);
                this.run_button.setVisible(true);
                this.pause_button.setVisible(true);
                this.resume_button.setVisible(true);
                this.reset_button.setVisible(true);
                this.load_button.setVisible(true);
            }
        }
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
