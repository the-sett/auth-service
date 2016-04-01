/**
 * A custom directive on the <canvas> element, that sets the canvas up with a UMLClassBuilder running on Paper.js,
 * to handle the contents of the canvas.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * <tr><td> Instantiate and configure paper.js
 * <tr><td> Instantiate the diagram manager.
 * <tr><td> Obtain a UMLClassBuilder from the diagram manager, and set up to delegate mouse events to it.
 *     <td> DiagramManager
 * <tr><td></td></tr>
 * </table>
 *
 * @constructor
 */
jModeller.directive('classEditor', function () {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {

            // Instantiate and configure paper.js
            paper.setup(element.get(0));
            var tool = new paper.Tool();

            // Instantiate the diagram manager.
            var diagramManager = new DiagramManager(tool);

            // Obtain a UMLClassInputMouseHandler from the diagram manager, and set up to delegate mouse events to it.
            var umlClassBuilder = diagramManager.umlClassBuilder();

            tool.onMouseDown = function (event) {
                if (!event.item) {
                    console.log("Mouse down on empty canvas.");

                    umlClassBuilder.onMouseDown(event);
                }
            };

            tool.onMouseDrag = function (event) {
                umlClassBuilder.onMouseDrag(event);
            };

            tool.onMouseUp = function (event) {
                umlClassBuilder.onMouseUp(event);
            };
        }
    };
});

