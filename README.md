# Formtastic grouped checkboxes

## Installation

Add this line to your application's Gemfile:

```ruby
gem "formtastic_grouped_check_boxes"
```

Import our Sass file “formtastic-grouped-check-boxes.css” in your CSS entrypoint that compiles CSS files:

```sass
// app/assets/stylesheets/application.sass

// Your regular ActiveAdmin files
@import ...
@import ...

// This gem’s files
@import "formtastic-grouped-check-boxes"
```

## Use

This gem adds a new input type `:grouped_check_boxes`.

It also adds 3 new input options, 2 of which follow the Rails naming convention from `grouped_collection_select`:

- `group_method` — The name of a method which, when called on a member of collection, returns an array of child objects. It can also be any object that responds to call, such as a proc, that will be called for each member of the collection to retrieve the value.
- `group_label_method` — The name of a method which, when called on a member of collection, returns a string to be used as the label attribute for its <optgroup> tag. It can also be any object that responds to call, such as a proc, that will be called for each member of the collection to retrieve the label.
- `group_label_parent` — Whether to prepend the fieldset label with the parent input title

```ruby
ActiveAdmin.register Project do
  permit_params technology_ids: []

  form do |f|
    f.inputs "Technologies" do
      f.input :technologies,
              as: :grouped_check_boxes, \
              collection: Technology.select(:id, :name, :area_id).includes(:area).order(:name), \
              group_method: :area, \
              group_label_method: :name, \
              group_label_parent: true
    end
  end
end
```

Providing that

```ruby
class Technology < ApplicationRecord
  belongs_to :area, foreign_key: :area_id, class_name: "TechnologyArea", optional: true
end
```

```ruby
class TechnologyArea < ApplicationRecord
  has_many :technologies
end
```

Results in

```html
<fieldset class="inputs">
  <legend><span>Technologies</span></legend>
  <ol>
    <li class="grouped_check_boxes check_boxes input optional" id="project_technologies_input">
      <input type="hidden" name="project[technology_ids][]" id="project_technologies_none" value="" autocomplete="off">

      <fieldset class="choices grouped_check_boxes__choices">
        <legend class="label grouped_check_boxes__legend">
          <label class="grouped_check_boxes__legend__label">Technologies / No subgroup</label>
        </legend>

        <ol class="choices-group grouped_check_boxes__choices-group">
          <li class="choice grouped_check_boxes__choice">
            <label for="project_technology_ids_46">
              <input type="checkbox" name="project[technology_ids][]" id="project_technology_ids_46" value="46">BitBucket
            </label>
          </li>
          <li class="choice grouped_check_boxes__choice">
            <label for="project_technology_ids_138">
              <input type="checkbox" name="project[technology_ids][]" id="project_technology_ids_138" value="138">BrainTree API (Ruby SDK)
            </label>
          </li>
        </ol>
      </fieldset>

      <fieldset class="choices grouped_check_boxes__choices">
        <legend class="label grouped_check_boxes__legend">
          <label class="grouped_check_boxes__legend__label">Technologies / Marketing</label>
        </legend>

        <ol class="choices-group grouped_check_boxes__choices-group">
          <li class="choice grouped_check_boxes__choice">
            <label for="project_technology_ids_59">
              <input type="checkbox" name="project[technology_ids][]" id="project_technology_ids_59" value="59">Direct sales
            </label>
          </li>
          <li class="choice grouped_check_boxes__choice">
            <label for="project_technology_ids_89">
              <input type="checkbox" name="project[technology_ids][]" id="project_technology_ids_89" value="89">Google Analytics
            </label>
          </li>
        </ol>
      </fieldset>
    </li>
  </ol>
</fieldset>
```
