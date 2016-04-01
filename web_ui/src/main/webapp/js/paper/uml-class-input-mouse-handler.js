/**
 * UMLClassInputMouseHandler defines the interactive process of drawing a UML class diagram with the mouse.
 *
 * <p/>One is created with an initial starting point, and subsequent points result in the specification of a bounding
 * box within which the diagram is to be drawn. Once the box has reached the initial size, the diagram definition is
 * valid, and a method is provided to test for validity.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * <tr><td> Handle mouse events relating to the input of a uml class diagram. </td></tr>
 * <tr><td> Turn pairs of points into bounding boxes for diagrams.</td></tr>
 * <tr><td> Notify when a diagram is positioned with a valid size and location. </td></tr>
 * </table>
 */
function UMLClassInputMouseHandler(modelBuilder, diagramManager) {
    /** Holds the diagram manager. */
    var diagramManager = diagramManager;

    /** Holds the model builder. */
    var modelBuilder = modelBuilder;

    /** Holds the custom drawing tool. */
    var drawing = new UMLClassDrawingUtils();

    /** Holds the starting point for the initial mouse down event. */
    var start;

    /** Holds the current top-left of the diagram bounding box. */
    var currentTopLeft;

    /** Holds the current bottom-right of the diagram bounding box. */
    var currentBottomRight;

    /** Flag used to indicate once the diagram has reached its capped size, and should be locked to it. */
    var lockedToSize = false;

    /** Holds the current uml class box being drawn. */
    var umlClassBox;

    /** A flag reset each time a valid mouse down event occurs to start drawing a diagram. */
    var mouseDownReset = false;

    /**
     * Starts drawing a class diagram when the mouse is pressed. It is the callers responsibility to check that the
     * mouse press is in a valid position/context to allow this to happen.
     *
     * @param event The mouse down event.
     */
    this.onMouseDown = function (event) {
        start = event.point;
        mouseDownReset = true;
    };

    /**
     * Checks if the mouse was dragged in the context of a valid mouse down event. If so, the diagram box is updated
     * with the current mouse position.
     *
     * @param event The mouse drag event.
     */
    this.onMouseDrag = function (event) {
        if (!mouseDownReset) {
            return;
        }

        if (umlClassBox) {
            umlClassBox.remove();
        }

        var points = this.mousePointsToBox(event.point);

        umlClassBox = drawing.drawUMLClassBox(points[0], points[1], true, this.isBoxValid());

        diagramManager.placeItemIntoComponents(umlClassBox);
    };

    /**
     * Checks if the mouse was released in the content of a valid mouse down event. If a valid diagram box results
     * from the whole mouse event, a new valid diagram is added to the drawing.
     *
     * @param event The mouse up event.
     */
    this.onMouseUp = function (event) {
        if (!mouseDownReset) {
            return;
        }

        if (umlClassBox) {
            umlClassBox.remove();
        }

        var points = this.mousePointsToBox(event.point);

        if (this.isBoxValid()) {
            var component = modelBuilder.addComponent();
            component.setPosition(points[0], points[1]);
            //diagramManager.placeItemIntoComponents(component.umlClassBox);

            // Ensure the current layout is saved as a starting point for the next one.
            diagramManager.saveCurrentPositions();
        }

        umlClassBox = null;
        mouseDownReset = false;
        currentBottomRight = null;
        currentTopLeft = null;
        start = null;
        lockedToSize = false;
    };

    /**
     * Checks if a box being added to a diagram is positioned and sized correctly to allow it to
     * be added to the diagram.
     *
     * @return boolean <tt>true</tt> iff the box is valid.
     */
    this.isBoxValid = function () {
        var height = Math.abs(currentBottomRight.y - currentTopLeft.y);
        var width = Math.abs(currentBottomRight.x - currentTopLeft.x);

        return (height >= this.classStartHeight && width >= this.classStartWidth);
    };

    /**
     * Transforms a pair of mouse coordinates taken from a mouse drag, into the bounding box for a
     * new class diagram.
     *
     * <p/>The following rules are applied:
     *
     * <pre><ol>
     * <li>The width and height of the box will be double the width and height of the input
     * box. This means that the current point will always function as the centre of the new box.</li>
     * <li>The maximum width and height will be capped at the initial height and width for
     * a new diagram, so the mouse will only stretch a new box to this size and no more.</li>
     * <li>The output coordinate pair will always have its first point as the top-left corner,
     * and the second point as its bottom-right corner, regardless of the direction of the mouse
     * drag input.</li>
     * </ol></pre>
     */
    this.mousePointsToBox = function (currentPoint) {
        // Calc abs height and width, used the full size once locked.
        var width = lockedToSize ? this.classStartWidth : 2.4 * Math.abs(currentPoint.x - start.x);
        var height = lockedToSize ? this.classStartHeight : 2.4 * Math.abs(currentPoint.y - start.y);

        // Cap height and width to the initial size.
        width = width > this.classStartWidth ? this.classStartWidth : width;
        height = height > this.classStartHeight ? this.classStartHeight : height;

        if (width >= this.classStartWidth && height >= this.classStartHeight) {
            lockedToSize = true;
        }

        // Transform to a pair of output points, centred on the current position.
        currentTopLeft = new paper.Point(currentPoint.x - width / 2, currentPoint.y - height / 2);
        currentBottomRight = new paper.Point(currentPoint.x + width / 2, currentPoint.y + height / 2);

        return [
            currentTopLeft,
            currentBottomRight
        ];
    };
}

/* Defines the starting size of a new class diagram. */
UMLClassInputMouseHandler.prototype.classStartWidth = 160;
UMLClassInputMouseHandler.prototype.classStartHeight = 70;
