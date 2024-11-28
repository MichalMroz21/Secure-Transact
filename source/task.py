from datetime import datetime

from PySide6.QtCore import QObject, Signal, Slot, Property

from enum import Enum

class Task(QObject):
    assigneesChanged = Signal()
    priorityChanged = Signal()
    statusChanged = Signal()
    commentsChanged = Signal()
    nameChanged = Signal()
    tagsChanged = Signal()
    due_dateChanged = Signal()

    class TaskPriority(Enum):
        LOW = 1
        MEDIUM = 2
        HIGH = 3
        URGENT = 4

    class TaskStatus(Enum):
        IN_PROGRESS = 0
        COMPLETED = 1
        FAILED = 2

    def __init__(self):
        super().__init__()

        self._assignees = [] #Users list
        self._due_date = datetime.today().isoformat()
        self._priority = self.TaskPriority.MEDIUM
        self._status = self.TaskStatus.IN_PROGRESS
        self._comments = [] #string list
        self._name = ""
        self._tags = [] #string list

    @Property("QVariantList", notify=assigneesChanged)
    def assignees(self):
        return self._assignees

    @Property(str, notify=due_dateChanged)
    def due_date(self):
        return self._due_date

    @Property(int, notify=priorityChanged)
    def priority(self):
        return self._priority

    @Property(int, notify=statusChanged)
    def status(self):
        return self._status

    @Property("QVariantList", notify=commentsChanged)
    def comments(self):
        return self._comments

    @Property(str, notify=nameChanged)
    def name(self):
        return self._name

    @Property("QVariantList", notify=tagsChanged)
    def tags(self):
        return self._tags

    @assignees.setter
    def assignees(self, new_val):
        if self._assignees != new_val:
            self._assignees = new_val
            self.assigneesChanged.emit()

    @due_date.setter
    def due_date(self, new_val):
        if self._due_date != new_val:
            self._due_date = new_val
            self.due_dateChanged.emit()

    @tags.setter
    def tags(self, new_val):
        if self._tags != new_val:
            self._tags = new_val
            self.tagsChanged.emit()

    @priority.setter
    def priority(self, new_val):
        if self._priority != new_val:
            self._priority = new_val
            self.priorityChanged.emit()

    @status.setter
    def status(self, new_val):
        if self._status != new_val:
            self._status = new_val
            self.statusChanged.emit()

    @comments.setter
    def comments(self, new_val):
        if self._comments != new_val:
            self._comments = new_val
            self.commentsChanged.emit()

    @name.setter
    def name(self, new_val):
        if self._name != new_val:
            self._name = new_val
            self.nameChanged.emit()

    def add_assignee(self, user):
        self.assignees.append(user)
        self.assigneesChanged.emit()

    def remove_assignee(self, user):
        self.assignees.remove(user)
        self.assigneesChanged.emit()

    def add_tag(self, tag):
        self.tags.append(tag)
        self.tagsChanged.emit()

    def remove_tag(self, tag):
        self.tags.remove(tag)
        self.tagsChanged.emit()

    def addComment(self, comment):
        self.comments.append(comment)
        self.commentsChanged.emit()

    def removeComment(self, comment):
        self.comments.remove(comment)
        self.commentsChanged.emit()
