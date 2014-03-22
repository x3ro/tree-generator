// Courtesy of http://sumtips.com/2012/06/tab-in-textarea.html
$("textarea").keydown(function(e) {
    if(e.keyCode === 9) { // tab was pressed
        // get caret position/selection
        var start = this.selectionStart;
            end = this.selectionEnd;

        var $this = $(this);

        // set textarea value to: text before caret + tab + text after caret
        $this.val($this.val().substring(0, start)
                    + "    "
                    + $this.val().substring(end));

        // put caret at right position again
        this.selectionStart = this.selectionEnd = start + 4;

        // prevent the focus lose
        return false;
    }
});
