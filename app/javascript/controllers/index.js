// Don't use /bin/rails stimulus:manifest:update to update this file:
// it enforces relative paths which break the importmap setup of the project.
// Instead, manually add new controllers to this file, following the format.

import { application } from "controllers/application";

import EditableController from "controllers/editable_controller";
application.register("editable", EditableController);

import NavbarController from "controllers/navbar_controller";
application.register("navbar", NavbarController);

import NotificationController from "controllers/notification_controller";
application.register("notification", NotificationController);

import SortableController from "controllers/sortable_controller";
application.register("sortable", SortableController);
