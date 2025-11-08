import { application } from "./application"
import EditableController from "./editable_controller"
import SortableController from "./sortable_controller"

application.register("editable", EditableController)
application.register("sortable", SortableController)
