require 'rails_helper'

feature 'Stages' do
  let(:company) { create :company }
  let(:user) { create :user, company: company }

  describe 'creating and updating a sales process' do
    before do
      login_as user, scope: :user
      visit '/settings/stages'
      expect(page).to have_css('#stages')
    end

    it 'creating a sales process', js: true do
      find('add-button.add-sales-process', text: 'Add').trigger('click')
      
      expect(page).to have_css('#sales-process-modal')

      within '#sales-process-modal' do
        fill_in 'name', with: 'Test Sales Process'
        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#sales-process-modal')

      within '.table-wrapper.table-sales-processes tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr' do
          expect(page).to have_text 'Test Sales Process'
        end

        find('i.fa-pencil', visible: false).trigger('click')
      end

      expect(page).to have_css('#sales-process-modal')

      within '#sales-process-modal' do
        fill_in 'name', with: 'Test'

        find_button('Save').trigger('click')
      end

      expect(page).to have_no_css('#sales-process-modal')

      within '.table-wrapper.table-sales-processes tbody' do
        expect(find('tr:first-child td:first-child')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(2)')).to have_text('Active')
      end
    end
  end

  describe 'creating and updating a stage' do
    let!(:sales_process) { create :sales_process, company: company}

    before do
      login_as user, scope: :user
      visit '/settings/stages'
      expect(page).to have_css('#stages')
    end

    it 'creating a stage', js: true do
      find('add-button.add-stage', text: 'Add').trigger('click')

      expect(page).to have_css('#stage-modal')

      within '#stage-modal' do
        fill_in 'name', with: 'Test Stage'
        fill_in 'probability', with: '64'
        ui_select('sales-process', sales_process.name)
        find_button('Create').trigger('click')
      end

      expect(page).to have_no_css('#stage-modal')

      within '.table-wrapper.table-stages tbody' do
        expect(page).to have_css('tr', count: 1)

        within 'tr' do
          expect(page).to have_text 'Test Stage'
          expect(page).to have_text '64%'
        end

        find('i.fa-pencil', visible: false).trigger('click')
      end

      expect(page).to have_css('#stage-modal')

      within '#stage-modal' do
        fill_in 'name', with: 'Test'
        fill_in 'probability', with: '80'

        find_button('Save').trigger('click')
      end

      expect(page).to have_no_css('#stage-modal')

      within '.table-wrapper.table-stages tbody' do
        expect(find('tr:first-child td:first-child')).to have_text('Test')
        expect(find('tr:first-child td:nth-child(2)')).to have_text(sales_process.name)
        expect(find('tr:first-child td:nth-child(3)')).to have_text('80%')
      end
    end
  end
end
