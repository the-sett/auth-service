/**
 * ModelBuilder provides methods to construct model instances. The model can then be 'built' into an
 * object that represents it, and is valid json accepted by the back-ends model.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * </table>
 *
 * @constructor
 */
function ModelBuilder() {
    this.components = [];
}

ModelBuilder.prototype = {
    /**
     * Adds a new enum definition to the model, and supplies a builder to construct that enum definition
     * with.
     *
     * OR maybe an enum (and other type defs) are simple enough that one can be built in a single pass
     * with no further builder needed?
     */
    addEnumDef: function () {
    },

    /**
     * Adds a new component to the model, and supplies a builder to construct that component with.
     *
     * @Return Component A builder to construct the component with.
     */
    addComponent: function () {
        console.log("ModelBuilder.addComponent: called");

        var component = new Component();
        this.components.push(component);

        return component;
    }
};

/**
 * Component provides methods to construct component instances.
 *
 * <p/><table id="crc"><caption>CRC Card</caption>
 * <tr><th> Responsibilities </th><th> Collaborations </th></tr>
 * </table>
 *
 * @constructor
 */
function Component() {
    /** Holds the custom drawing tool. */
    this.drawing = new UMLClassDrawingUtils();

    /** Holds the on-screen paper.js item for the diagram. */
    this.umlClassBox = null;

    /** Holds the bounding box for the diagram. */
    this.bounds = null;

    /** Can be used to save the bounding box position. */
    this.savedBounds = null;

    this.restored = true;
}

Component.prototype = {
    setPosition: function (topLeft, bottomRight) {
        this.bounds = new paper.Rectangle(topLeft, bottomRight);

        // Adjust the position on screen.
        this.createOrMove();
    },

    /**
     * Adjusts the position of the diagram box on screen, or creates it for the first time if it does not already exist.
     */
    createOrMove: function () {
        if (this.umlClassBox)
            this.umlClassBox.bounds = this.bounds;
        else
            this.umlClassBox = this.drawing.drawUMLClassBox(this.bounds.topLeft, this.bounds.bottomRight, false, true);        

        // Capture the current position in the bounding box.
        this.bounds = new paper.Rectangle(this.umlClassBox.bounds);
        
        console.log("createOrMove: " + this.umlClassBox);
    },

    /** Saves the current bounding box. */
    saveBounds: function () {
        this.savedBounds = new paper.Rectangle(this.bounds);
        //console.log("saveBounds: " + this.savedBounds);
    },

    /** Restores the current bounding box from the saved value. */
    restoreBounds: function () {
        if (this.restored)
            return;
        
        //console.log("restoreBounds");

        this.setPosition(new paper.Point(this.savedBounds.x, this.savedBounds.y),
            new paper.Point(this.savedBounds.x + this.savedBounds.width,
                            this.savedBounds.y + this.savedBounds.height));

        this.restored = true;
    },

    /**
     * Adjusts the current bounding box by a vector relative to the saved one. This also updates the on-screen
     * position to the new bounding box.
     */
    adjustBoundsRelativeToSaved: function (vector) {
        console.log("adjustBoundsRelativeToSaved: " + vector);
        
        this.setPosition(new paper.Point(this.savedBounds.x + vector.x, this.savedBounds.y + vector.y),
            new paper.Point(this.savedBounds.x + vector.x + this.savedBounds.width,
                            this.savedBounds.y + vector.y + this.savedBounds.height));

        this.restored = false;
    }
};
