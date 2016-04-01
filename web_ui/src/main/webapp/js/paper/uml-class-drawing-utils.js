/**
 * UMLClassDrawingUtils defines some drawing utilities for rendering UML class diagrams.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * <tr><td> Draw a UML class diagram.
 * </table>
 *
 * @constructor
 */
function UMLClassDrawingUtils() {
    /**
     * Produces a box, which is part of a UML class diagram; either the upper or lower portion.
     * The box may be selected to be in 'ghost' format (usually used to render a preview of it).
     * The box may also be selected to be in valid or invalid styling (invalid styling is usually
     * used when the box is being previewed in an invalid location or size).
     *
     * @param topLeft     The top-left corner of the box part.
     * @param bottomRight The bottom-right corner of the box part.
     * @param upper       true iff the upper section of the diagram is being rendered.
     * @param ghost       true iff ghost styling should be used.
     * @param valid       true iff valid styling should be used.
     *
     * @return All paths that make up the box as a group.
     */
    this.drawUMLClassPartBox = function (topLeft, bottomRight, upper, ghost, valid) {
        var bottomLeft = this.toBottomLeft(topLeft, bottomRight);
        var topRight = this.toTopRight(topLeft, bottomRight);

        var color = ghost ? this.colGhost : this.colStandard;

        // Fill in the background if valid.
        var background;

        if (valid) {
            var box = new paper.Rectangle(topLeft, bottomRight);
            background = new paper.Path.Rectangle(box);
            background.fillColor = 'white';
            background.strokeWidth = 0;
        }

        // Draw the box as a group of separate lines, to allow for independent line styles.
        var left = this.line(topLeft, bottomLeft, color, this.thin);
        var right = this.line(topRight, bottomRight, color, this.thin);
        var top = this.line(topLeft, topRight, color, upper ? this.thickest : this.thin);
        var bottom = this.line(bottomLeft, bottomRight, color, upper ? this.thin : this.thick);

        var group = new paper.Group([left, right, top, bottom]);

        // Set invalid styling if required.
        if (!valid) {
            group.children.map(function (path) {
                path.dashArray = [3, 2];
            });
        }

        if (background) {
            group.insertChild(0, background);
        }

        return group;
    }
}

UMLClassDrawingUtils.prototype = Object.create(DrawingUtils.prototype, {
    /**
     * Produces a box for a UML class diagram.
     * The box may be selected to be in 'ghost' format (usually used to render a preview of it).
     * The box may also be selected to be in valid or invalid styling (invalid styling is usually
     * used when the box is being previewed in an invalid location or size).
     *
     * @param topLeft     The top-left corner of the box part.
     * @param bottomRight The bottom-right corner of the box part.
     * @param ghost       true iff ghost styling should be used.
     * @param valid       true iff valid styling should be used.
     *
     * @return All paths that make up the box as a group.
     */
    drawUMLClassBox: {
        value: function (topLeft, bottomRight, ghost, valid) {
            // The height of the bottom section is the smaller of a fixed height or half the overall height.
            var totalHeight = (bottomRight.y - topLeft.y);
            var bottomHeight = totalHeight / 2;
            bottomHeight = bottomHeight > 20 ? 20 : bottomHeight;
            var topHeight = totalHeight - bottomHeight;

            var topLeftOfBottom = new paper.Point(topLeft.x, topLeft.y + topHeight);
            var bottomRightOfTop = this.toTopRight(topLeftOfBottom, bottomRight);

            var topPart = this.drawUMLClassPartBox(topLeft, bottomRightOfTop, true, ghost, valid);
            var bottomPart = this.drawUMLClassPartBox(topLeftOfBottom, bottomRight, false, ghost, valid);

            var diagGroup = new paper.Group([topPart, bottomPart]);

            diagGroup.onMouseDown = function (event) {
                console.log("Mouse down on UML class diagram.");
            };

            var topLeftBuffer = new paper.Point(topLeft.x - this.bufferZone, topLeft.y - this.bufferZone);
            var bottomRightBuffer = new paper.Point(bottomRight.x + this.bufferZone, bottomRight.y + this.bufferZone);

            var bufferBox = new paper.Rectangle(topLeftBuffer, bottomRightBuffer);
            var bufferZone = new paper.Path.Rectangle(bufferBox);
            bufferZone.fillColor = 'white';
            bufferZone.strokeWidth = 0;

            bufferZone.onMouseEnter = function (event) {
                console.log("Mouse entered the buffer zone.");
            };

            var group = new paper.Group([bufferZone, diagGroup]);

            return group;
        }
    }
});
