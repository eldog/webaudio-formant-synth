getMidiInputs = function (handle, array) {
  handle.inputs.values(function () {
    console.log(arguments);
  });
};
