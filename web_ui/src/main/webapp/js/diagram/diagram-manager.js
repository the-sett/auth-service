/**
 * DiagramManager is the over-all manager for a model and its diagrams.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * <tr><td></td></tr>
 * </table>
 *
 * @constructor
 */
function DiagramManager(tool) {
    /** Holds the paper.js Tool. */
    this.tool = tool;

    /** Holds the model builder. */
    this.modelBuilder = new ModelBuilder();
}

DiagramManager.prototype = {
    umlClassBuilder: function () {
        return new UMLClassInputMouseHandler(this.modelBuilder, this);
    },

    /**
     * Saves the current positions of all items in the diagram. This should be done prior to placing a new item into the
     * diagram, so that items being moved can revert to their current position where possible.
     */
    saveCurrentPositions: function () {
        this.modelBuilder.components.map(function (item) {
            item.saveBounds();
        });
    },

    /**
     * Places a paper.js item into a diagram of components. The components are moved radially outwards by their centers
     * form the center of the item being placed into the diagram, in order to make room for the new item.
     *
     * @param item The item to place into the diagram.
     */
    placeItemIntoComponents: function (item) {
        // Copy the array of components, as it will be modified by the placement algorithm.
        var sortedComponents = this.modelBuilder.components.slice();

        // Center everything on the initial item being placed into the diagram.
        var center = item.bounds.center;

        // Sort the components by distance from the component being placed into the diagram.
        var distanceToCenter = this.distanceToPoint(center);

        sortedComponents.sort(function (first, second) {
            var firstDistance = distanceToCenter(first);
            var secondDistance = distanceToCenter(second);


            if (firstDistance < secondDistance)
                return -1;
            else if (firstDistance > secondDistance)
                return 1;
            else
                return 0;
        });

        var rect1 = item.bounds;

        // Debug
        new paper.Path.Rectangle({point: rect1.topLeft, size: rect1.size, strokeColor: 'red'})
            .removeOnDrag().removeOnMove();

        this.innerPlace(center, sortedComponents, item);
    },

    /**
     * The inner loop of the placement algorithm.
     *
     * @param center           The center to radiate positioning outwards from.
     * @param sortedComponents The components still to be placed, sorted outwards from the center.
     * @param item             The current item to place.
     */
    innerPlace: function (center, sortedComponents, item) {
        // For each component, check for overlaps with the one being placed, and move the component outward radially,
        // from the original centre point of the first component being placed, until it does not overlap.
        var rect1 = item.bounds;

        for (var i = 0; i < sortedComponents.length; i++) {
            var component = sortedComponents[i];
            var rect2 = component.savedBounds;

            // Debug
            new paper.Path.Rectangle({point: rect2.topLeft, size: rect2.size, strokeColor: 'blue'})
                .removeOnDrag().removeOnMove();

            if (rect2.intersects(rect1)) {
                // Calculate the overlap vector, and the vector between the centres of (mass of) the rectangles.
                var intersect = rect2.intersect(rect1);

                var intersectRect = new paper.Path.Rectangle({
                    point: intersect.topLeft,
                    size: intersect.size
                }).removeOnDrag().removeOnMove();

                var centerLine = new paper.Path.Line({from: rect1.center, to: rect2.center});
                centerLine.scale(40);

                // Debug
                var debugLine = new paper.Path.Line({from: rect1.center, to: rect2.center, strokeColor: 'green'})
                    .removeOnDrag().removeOnMove();

                var intersections = centerLine.getIntersections(intersectRect);

                // Debug
                for (var j = 0; j < intersections.length; j++) {
                    new paper.Path.Circle({
                        center: intersections[j].point,
                        radius: 4,
                        fillColor: j % 2 == 0 ? 'red' : 'blue'
                    }).removeOnDrag().removeOnMove();
                }

                if (intersections.length > 0) {
                    var move = new paper.Point(intersections[1].point.x - intersections[0].point.x, intersections[1].point.y - intersections[0].point.y);

                    // Moved the overlapped component by the projection vector.
                    component.adjustBoundsRelativeToSaved(move);
                }

                // Debug
                var debugRect = component.bounds;
                new paper.Path.Rectangle({point: debugRect.topLeft, size: debugRect.size, strokeColor: 'green'})
                    .removeOnDrag().removeOnMove();
            }
            else {
                //component.restoreBounds();
            }
        }

        // Repeat for each component in the sorted list, popping them off as we go.
        var nextComponent = sortedComponents.shift();

        if (!nextComponent)
            return;        

        var nextItem = nextComponent.umlClassBox;

        if (sortedComponents.length >= 1)
            this.innerPlace(center, sortedComponents, nextItem);
    },

    /**
     * Projects vector2 onto vector1.
     *
     * @param vector1 The vector to project onto.
     * @param vector2 The vector to project.
     *
     * @returns Point The projection vector.
     */
    project: function (vector1, vector2) {
        var scalar = (vector2.dot(vector1)) / (vector1.dot(vector1));
        scalar = Math.abs(scalar);
        var projection = new paper.Point(vector1.x * scalar, vector1.y * scalar);

        return projection;
    },

    /**
     * Supplies a function that calculates the distance between the centre of a component diagram, to a given point.
     * @param point The point to calculate the centre distance from.
     *
     * @returns {Function} A function that calculates the distance between the centre of a component diagram, to a
     * given point.
     */
    distanceToPoint: function (point) {
        return function (component) {
            var center = component.savedBounds.center;
            return center.getDistance(point);
        }
    }
};
