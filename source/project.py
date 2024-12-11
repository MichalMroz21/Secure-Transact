import json

from PySide6.QtCore import QObject, Signal, Slot, Property


class Project(QObject):
    tasksChanged = Signal()
    nameChanged = Signal()
    usersChanged = Signal()
    idChanged = Signal()

    def __init__(self, name="Project", users = None, tasks = None, id = None):
        super().__init__()

        self._tasks = tasks if tasks is not None else []
        self._name = name
        self._users = users if users is not None else []
        from random import randint
        self._id = id if id is not None else randint(0, 2147483647)

    def to_dict(self):
        return {
            "tasks": [task.to_dict() for task in self._tasks],
            "name": self._name,
            "users": [user.to_dict() for user in self._users],
            "id": self._id
        }

    def to_JSON(self):
        return json.dumps(self.to_dict())

    @staticmethod
    def from_dict(data):
        json_tasks = data["tasks"]
        from task import Task
        tasks = [Task().from_dict(task) for task in json_tasks]
        names = data["name"]
        json_users = data["users"]
        from user import User
        users = [User().from_dict(user) for user in json_users]
        id = int(data["id"])
        return Project(names, users, tasks, id)

    @staticmethod
    def from_JSON(JSON):
        return Project.from_dict(json.loads(JSON))

    @Property("QVariantList", notify=tasksChanged)
    def tasks(self):
        return [task.to_dict() for task in self._tasks]

    def get_tasks(self):
        return self._tasks

    @Property(str, notify=nameChanged)
    def name(self):
        return self._name

    @Property("QVariantList", notify=usersChanged)
    def users(self):
        return [user.to_dict() for user in self._users]

    def get_users(self):
        return self._users

    @Property(int, notify=idChanged)
    def id(self):
        return self._id

    @id.setter
    def id(self, new_val):
        if self._id != new_val:
            self._id = new_val
            self.idChanged.emit()

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
