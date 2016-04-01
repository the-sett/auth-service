/**
 * DrawingUtils defines some basic drawing behavious that can be re-used.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * <tr><td> Work out the implied corners of a bounding box.
 * <tr><td> Draw lines with a limited selection of styling.
 * </table>
 *
 * @constructor
 */
function DrawingUtils() {
}

DrawingUtils.prototype = {
    /* Some standard stroke widths. */
    thin: 1,
    thick: 2,
    thickest: 4,

    /* Some standard colors. */
    colStandard: 'black',
    colGhost: 'grey',

    /* Standard sizes. */
    bufferZone: 10,

    /**
     * Produces a new point, which is the left-most, bottom-most of the supplied bounding box.
     *
     * @param topLeft     The top left corner of a boudning box.
     * @param bottomRight The bottom right corner of a bounding box.
     */
    toBottomLeft: function (topLeft, bottomRight) {
        return new paper.Point(topLeft.x, bottomRight.y);
    },

    /**
     * Produces a new point, which is the right-most, top-most of the supplied bounding box.
     *
     * @param topLeft     The top left corner of a boudning box.
     * @param bottomRight The bottom right corner of a bounding box.
     */
    toTopRight: function (topLeft, bottomRight) {
        return new paper.Point(bottomRight.x, topLeft.y);
    },

    /**
     * Produces a line between two points in the specified color and line width.
     *
     * @param from  The point from.
     * @param to    The point to.
     * @param color The line color.
     * @param width The line width.
     */
    line: function (from, to, color, width) {
        var line = new paper.Path.Line(from, to);
        line.strokeColor = color;
        line.strokeWidth = width;

        return line;
    },

    /**
     * Creates some re-usable symbols.
     */
    initSymbols: function () {
    }
};