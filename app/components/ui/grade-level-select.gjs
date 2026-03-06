import { eq } from 'frontend/utils/stdlib';
import { helper } from '@ember/component/helper';
import UiSelect from './select';

const str = helper(([value]) => (value == null ? '' : String(value)));

const GRADE_OPTIONS = [
  { value: '-1', label: 'Pre-K' },
  { value: '0', label: 'Kindergarten' },
  { value: '1', label: '1st' },
  { value: '2', label: '2nd' },
  { value: '3', label: '3rd' },
  { value: '4', label: '4th' },
  { value: '5', label: '5th' },
  { value: '6', label: '6th' },
  { value: '7', label: '7th' },
  { value: '8', label: '8th' },
  { value: '9', label: '9th' },
  { value: '10', label: '10th' },
  { value: '11', label: '11th' },
  { value: '12', label: '12th' },
];

export function gradeLabel(grade) {
  if (grade == null || grade === '') return '';
  return GRADE_OPTIONS.find((o) => String(o.value) === String(grade))?.label ?? '';
}

<template>
  <UiSelect
    @label={{@label}}
    @id={{@id}}
    @placeholder={{if @placeholder @placeholder "Select grade..."}}
    @hint={{@hint}}
    @error={{@error}}
    ...attributes
  >
    {{#each GRADE_OPTIONS as |opt|}}
      <option value={{opt.value}} selected={{if (eq (str @value) opt.value) true}}>
        {{opt.label}}
      </option>
    {{/each}}
  </UiSelect>
</template>
