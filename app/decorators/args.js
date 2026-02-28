import { assert } from '@ember/debug';
import { isProduction } from '../utils/environment';
import { isArray } from '@ember/array';
import GlimmerComponent from '@glimmer/component';

/*

Defines the arguments for a component.  For example:

@args({
  selected: { required: true },
  placeholder: { type: 'string', defaultValue: '(no organization selected)' },
  renderInPlace: { type: 'boolean', defaultValue: false },
  required: { type: 'boolean', defaultValue: true },
  onChange: { type: 'function', defaultValue() {} }
})
export default class OrganizationSelect extends Component {
  ...
}

Each key is the name of an argument.  Only specified arguments are allowed, so they must be defined if used.

Properties for each argument:

* `required`: Asserts that the argument is specified. It does not validate the presence of its value,
    just the presence of the argument.
* `type`: Asserts the type. It can be any string that typeof returns or an actual class such as
    String, Date, Number, or even domain-specific classes like User!
* `array`: Asserts that the value is an array.  When used in conjunction with `type`,
    it asserts that all items in the array are of the specified type.
* `allowNull`: Used in conjunction with `type` to allow the value to be of the specified type or null / undefined.


For validation, Glimmer components do not have a similar mechanism to watch when "any" argument changes,
but if necessary, this can be accomplished by adding {{this.validateArgs}} to the template.  Typically, validation upon
create should be sufficient.

In production mode, the component class is returned unmodified.
*/

function validateRequired(definition, args) {
  for (const [ key, config ] of Object.entries(definition)) {
    if (config.required && !(key in args)) {
      assert(`Missing required argument: '${key}'`);
    }
  }
}

function validateType({ type, array, allowNull }, value) {
  if (allowNull && ((value === null) || (value === undefined))) {
    return true;
  }

  if (array) {
    return isArray(value) && value.every((v) => validateType({ type, allowNull }, v));
  }

  if (typeof type === 'string') {
    return typeof value === type;
  }

  // String, Date, or even custom classes like a User model
  if (typeof type === 'function') {
    return value instanceof type;
  }

  return false;
}

function validateTypes(definition, args) {
  for (const [key, config] of Object.entries(definition)) {
    if (key in args && config.type) {
      const value = args[key];
      const isValid = validateType(config, value);
      assert(
        `Argument '${key}' is expected to be of type '${config.type}', but got '${typeof value}'`,
        isValid
      );
    }
  }
}

function validateUnknown(definition, args) {
  const unknownArguments = Object.keys(args).filter(key => !(key in definition));
  if (unknownArguments.length) {
    assert(`Unexpected arguments: ${unknownArguments.join(', ')}`);
  }
}

function validateArguments(definition, args) {
  args = args || {};
  validateRequired(definition, args);
  validateTypes(definition, args);
  validateUnknown(definition, args);
}

function buildGlimmerComponentClass(ComponentClass, definition) {
  return class extends ComponentClass {
    constructor(owner, args) {
      super(owner, args);
      validateArguments(definition, args);
    }

    // Optional rerender-time check -- just add {{this.validateArgs}} to your template
    get validateArgs() {
      validateArguments(definition, this.args);
      return true;
    }
  };
}

export default function args(definition) {
  return function (ComponentClass) {
    const isGlimmerComponent = ComponentClass.prototype instanceof GlimmerComponent;

    if (isProduction) {
      // otherwise, just return the unmodified component class itself
      return ComponentClass;
    }

    if (isGlimmerComponent) {
      return buildGlimmerComponentClass(ComponentClass, definition);
    }

    assert(`Unknown component class: ${ComponentClass}`);
  };
}
