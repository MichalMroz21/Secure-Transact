import json

from PySide6.QtCore import QObject, Signal, Slot, Property

class Project(QObject):
    tasksChanged = Signal()
    nameChanged = Signal()
    usersChanged = Signal()

    def __init__(self, name="Project", users = None, tasks = None):
        super().__init__()

        self._tasks = tasks if tasks is not None else []
        self._name = name
        self._users = users if users is not None else []

    def to_JSON(self):
        JSON = {
            "tasks": [task.to_JSON() for task in self._tasks],
            "name": self._name,
            "users": [user.to_JSON() for user in self._users]
        }
        return json.dumps(JSON)

    @staticmethod
    def from_JSON(JSON):
        json_array = json.loads(JSON)
        tasks = json_array["tasks"]
        names = json_array["name"]
        users = json_array["users"]
        return Project(names, users, tasks)

    @Property("QVariantList", notify=tasksChanged)
    def tasks(self):
        return self._tasks

    @Property(str, notify=nameChanged)
    def name(self):
        return self._name

    @Property("QVariantList", notify=usersChanged)
    def users(self):
        return self._users

    @tasks.setter
    def tasks(self, new_val):
        if self._tasks != new_val:
            self._tasks = new_val
            self.tasksChanged.emit()

    @name.setter
    def name(self, new_val):
        if self._name != new_val:
            self._name = new_val
            self.nameChanged.emit()

    @users.setter
    def users(self, new_val):
        if self._users != new_val:
            self._users = new_val
            self.usersChanged.emit()

    @Slot(QObject)
    def add_user(self, user):
        self.users.append(user)
        self.usersChanged.emit()

    @Slot(QObject)
    def remove_user(self, user):
        self.users.remove(user)
        self.usersChanged.emit()

    @Slot(QObject)
    def add_task(self, task):
        self.tasks.append(task)
        self.tasksChanged.emit()

    @Slot(QObject)
    def remove_task(self, task):
        self.tasks.remove(task)
        self.tasksChanged.emit()
