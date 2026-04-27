# ClientX.problems
Android status bar and client height/width problems
//This programme is written to get around a couple of android problems.
// Android 15 brought the status bar and the navigation bar into the area
// provided for the user to write on.  Sort of neat, and uses some of the
// space which is otherwise not available, but the side effects are
// 1. The lettering in the space bar may be difficult to read due to
// the colour of the user's images and things, and
// 2. If you put your buttons at the bottom of the screen, they are no
// longer useful, as they are now behind the navigation bar.

// There is another problem which rather baffles me.
// If in Form.Create you access the CLientHeight and ClientWidth, you will
// find that the value for the vertical one (depending on orientation) is
// short by the height iof the status bar.  On top of this, screen rotation
// can lead to the CLientHeight and ClientWidths values being crossed, with
// odd results!
