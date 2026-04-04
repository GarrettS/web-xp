var tasks = [];
var id = 0;

function addTask() {
  var inp = document.getElementById("inp");
  var val = inp.value;
  if (val == "") return;

  var li = document.createElement("li");
  li.innerHTML = val + ' <button onclick="toggleDone(' + id + ')">Done</button> <button onclick="removeTask(' + id + ')">Remove</button>';
  li.id = id;
  li.style.padding = "8px";
  li.style.borderBottom = "1px solid #eee";
  document.getElementById("list").appendChild(li);

  tasks.push({ id: id, text: val, done: false });
  id++;
  inp.value = "";
}

function toggleDone(taskId) {
  var items = document.querySelectorAll("#list li");
  for (var i = 0; i < items.length; i++) {
    if (items[i].id == taskId) {
      items[i].classList.toggle("done");
      break;
    }
  }
  var task = tasks.find(function(t) { return t.id == taskId; });
  if (task) task.done = !task.done;
}

function removeTask(taskId) {
  var items = document.querySelectorAll("#list li");
  for (var i = 0; i < items.length; i++) {
    if (items[i].id == taskId) {
      items[i].remove();
      break;
    }
  }
  tasks = tasks.filter(function(t) { return t.id != taskId; });
}

function attachHandlers() {
  var buttons = document.querySelectorAll(".action-btn");
  for (var i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener("click", function() {
      var action = this.dataset.action;
      if (action == "clear") {
        document.getElementById("list").innerHTML = "";
        tasks = [];
      }
    });
  }
}

function saveToServer() {
  fetch("/api/tasks", {
    method: "POST",
    body: JSON.stringify(tasks)
  }).then(function(resp) {
    console.log("saved");
  });
}

function loadFromServer() {
  fetch("/api/tasks").then(function(resp) {
    return resp.json();
  }).then(function(data) {
    data.forEach(function(item) {
      addTask(item.text);
    });
  }).catch(function(err) {
  });
}

function initFilters() {
  var filters = ["all", "done", "active"];
  for (var i = 0; i < filters.length; i++) {
    var btn = document.createElement("button");
    btn.textContent = filters[i];
    btn.addEventListener("click", function() {
      filterTasks(this.textContent);
    });
    document.getElementById("filters").appendChild(btn);
  }
}

function filterTasks(type) {
  var items = document.querySelectorAll("#list li");
  for (var i = 0; i < items.length; i++) {
    if (type == "done") {
      items[i].style.display = items[i].classList.contains("done") ? "" : "none";
    } else if (type == "active") {
      items[i].style.display = items[i].classList.contains("done") ? "none" : "";
    } else {
      items[i].style.display = "";
    }
  }
}
