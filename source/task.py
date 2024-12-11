import json
from datetime import datetime

from PySide6.QtCore import QObject, Signal, Slot, Property

from enum import Enum

class Task(QObject):
    assigneeChanged = Signal()
    priorityChanged = Signal()
    statusChanged = Signal()
    commentsChanged = Signal()
    nameChanged = Signal()
    tagsChanged = Signal()
    due_dateChanged = Signal()

    class TaskPriority(int, Enum):
        LOW: int = 1
        MEDIUM: int = 2
        HIGH: int = 3
        URGENT: int = 4

    class TaskStatus(int, Enum):
        TO_DO: int = 0
        IN_PROGRESS: int = 1
        COMPLETED:int = 2
        FAILED:int = 3

    def __init__(self, assignee=None, due_date=datetime.today().isoformat(), priority=TaskPriority.MEDIUM, status=TaskStatus.TO_DO, comments=None, name="", tags=None):
        super().__init__()

        self._assignee = assignee
        self._due_date = due_date
        self._priority = priority
        self._status = status
        self._comments = [] if comments is None else comments #string list
        self._name = name
        self._tags = [] if tags is None else tags #string list

    def to_dict(self):
        return {
            "assignee": self._assignee.to_dict(),
            "due_date": str(self._due_date.date()),#e.g. 2006-09-09 is 10 characters long
            "priority": self._priority,
            "status": self._status,
            "comments": [comment for comment in self._comments],
            "name": self._name,
            "tags": [tag for tag in self._tags]
        }

    def to_JSON(self):
        return json.dumps(self.to_dict(), sort_keys=True, separators=(',', ':'))

    @staticmethod
    def from_dict(data):
        json_assignee = data["assignee"]
        from user import User
        assignee = User.from_dict(json_assignee)
        json_due_date = data["due_date"]
        due_date = datetime.strptime(json_due_date, "%Y-%m-%d")
        priority = data["priority"]
        status = data["status"]
        json_comments = data["comments"]
        comments = [comment for comment in json_comments]
        name = data["name"]
        json_tags = data["tags"]
        tags = [tag for tag in json_tags]
        return Task(assignee, due_date, priority, status, comments, name, tags)

    @staticmethod
    def from_JSON(JSON: str):
        return Task.from_dict(json.loads(JSON))

    @Property(QObject, notify=assigneeChanged)
    def assignee(self):
        return self._assignee.to_dict()

    @Property(str, notify=due_dateChanged)
    def due_date(self):
        date_string = self._due_date.date().isoformat()
        return date_string

    @Property(int, notify=priorityChanged)
    def priority(self):
        return self._priority

    @Property(int, notify=statusChanged)
    def status(self):
        return self._status

    @Property("QVariantList", notify=commentsChanged)
    def comments(self):
        return [comment for comment in self._comments]

    def get_comments(self):
        return self._comments

    @Property(str, notify=nameChanged)
    def name(self):
        return self._name

    @Property("QVariantList", notify=tagsChanged)
    def tags(self):
        return [tag for tag in self._tags]

    def get_tags(self):
        return self._tags

    @assignee.setter
    def assignee(self, new_val):
        if self._assignee != new_val:
            self._assignee = new_val
            self.assigneeChanged.emit()

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
