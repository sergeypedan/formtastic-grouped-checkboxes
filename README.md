# Formtastic grouped checkboxes

[![Gem Version](https://badge.fury.io/rb/formtastic_grouped_check_boxes.svg)](https://badge.fury.io/rb/formtastic_grouped_check_boxes)

Group your Formtastic checkboxes like grouped select via “grouped_collection_select” in Rails.

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

### Example

Providing that our models look like so:

```ruby
class Project < ApplicationRecord
  has_many :technologies # details omitted
  accepts_nested_attributes_for :technologies
end
```

```ruby
class Technology < ApplicationRecord
  has_many :projects # details omitted
  belongs_to :area, foreign_key: :area_id, class_name: "TechnologyArea", optional: true
end

# Table name: technologies
#  id       :bigint  not null, primary key
#  name     :string  not null
#  area_id  :bigint
```

```ruby
class TechnologyArea < ApplicationRecord
  has_many :technologies
end

# Table name: technology_areas
#  id    :bigint  not null, primary key
#  name  :string  not null
```

In ActiveAdmin you can do the following

```ruby
ActiveAdmin.register Project do
  permit_params technology_ids: [], ...

  form do |f|
    f.inputs "Technologies" do
      f.input :technologies,
              as: :grouped_check_boxes, \
              collection: Technology.order(:name) \
                          .select(:id, :name, :area_id) \ # note the `:area_id`
                          .includes(:area), \ # prevent N+1
              group_method: :area, \ # calls `.area` on each instance of `Technology` (that’s why we need `:area_id`)
              group_label_method: :name, \ # calls `.name` on each instance of `TechnologyArea`
              group_label_parent: true # not required
    end
  end
end
```

Results in:

![screenshot-1](https://github.com/sergeypedan/formtastic-grouped-checkboxes/assets/2311484/7f553b64-d461-4d60-845d-829ba36e3768)

While producing such code:

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
