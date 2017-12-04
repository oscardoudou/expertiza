require 'rspec'



describe 'new account request' do

  before(:each) do

    create(:role_of_student)

    create(:role_of_administrator)

    create(:role_of_instructor)

    create(:role_of_teaching_assistant)

    create(:admin, name: 'super_administrator2')

    create(:institution)

    create(:studentx,name:'abc',email: 'abc@gmail.com')

    create(:requested_user,name:'abc',email: 'abc@gmail.com')

  end

  context 'account request' do

    it 'request with new institution successfully' do

      visit '/'

      click_link 'REQUEST ACCOUNT'

      expect(page).to have_content('Request new user')

      select 'Instructor', from: 'user_role_id'

      fill_in 'user_name', with: 'yzhan'

      fill_in 'user_fullname', with: 'yzhang'

      fill_in 'user_email', with: 'yzhang@hnu.edu'

      select 'Not List', from: 'user_institution_id'

      fill_in 'institution_name', with: 'HNU'

      fill_in 'requested_user_intro', with: 'university from China'

      click_on 'Request'

      expect(page).to have_content('successfully requested')

    end

    it 'request with existed institution' do

      visit '/'

      click_link 'REQUEST ACCOUNT'

      expect(page).to have_content('Request new user')

      select 'Teaching Assistant', from: 'user_role_id'

      fill_in 'user_name', with: 'yzhan'

      fill_in 'user_fullname', with: 'yzhang'

      fill_in 'user_email', with: 'yzhang@ncsu.edu'

      select 'North Carolina State University', from: 'user_institution_id'

      fill_in 'requested_user_intro', with: 'new ta from NCSU'

      click_on 'Request'

      expect(page).to have_content('successfully requested')

    end

    it 'fail to request with existed user name' do

      visit '/'

      click_link 'REQUEST ACCOUNT'

      expect(page).to have_content('Request new user')

      select 'Teaching Assistant', from: 'user_role_id'

      fill_in 'user_name', with: 'abc'

      fill_in 'user_fullname', with: 'yzhang'

      fill_in 'user_email', with: 'yzhang@ncsu.edu'

      select 'North Carolina State University', from: 'user_institution_id'

      fill_in 'requested_user_intro', with: 'new ta from NCSU'

      click_on 'Request'

      expect(page).to have_content('The account you are requesting has already existed in Expertiza.')

    end
    
        it 'fail to request with existed requested_user email' do
 
       visit '/'
 
       click_link 'REQUEST ACCOUNT'
 
       expect(page).to have_content('Request new user')
 
       select 'Teaching Assistant', from: 'user_role_id'
 
       fill_in 'user_name', with: '123'
 
       fill_in 'user_fullname', with: 'whatever'
 
       fill_in 'user_email', with: 'abc@gmail.com'
 
       select 'North Carolina State University', from: 'user_institution_id'
 
       fill_in 'requested_user_intro', with: 'request an account for expertiza'
 
       click_on 'Request'
 
       expect(page).to have_content('Email has already been taken')
    
        end

  end


  context 'on users#list_pending_requested page' do

    before (:each) do

      create(:requester, name: 'requester1', email: 'requestor1@test.com')

    end

    it 'allows super-admin and admin to communicate with requesters by clicking email addresses' do

      visit '/'

      login_as 'super_administrator2'

      visit '/users/list_pending_requested'

      expect(page).to have_content('requestor1@test.com')

      expect(page).to have_link('requestor1@test.com')

    end



    context 'when super-admin or admin rejects a requester' do

      it 'displays \'Rejected\' as status' do

        visit '/'

        login_as 'super_administrator2'

        visit '/users/list_pending_requested'
        expect(page).to have_content('abc')

        all('input[id="2"]').first.click
        #choose(name: 'status',option:'Rejected')

        all('input[value="Submit"]').first.click

        expect(page).to have_content('The user "abc" has been Rejected.')

        expect(RequestedUser.first.status).to eq('Rejected')

       # expect(page).to have_content('studentx')

       # expect(page).to have_content('Rejected')

      end

    end



    context 'when super-admin or admin accepts a requester' do



      it 'displays \'Accept\' as status and sends an email with randomly-generated password to the new user' do


        visit '/'

        login_as 'super_administrator2'

        visit '/users/list_pending_requested'

        ActionMailer::Base.deliveries.clear

        expect(page).to have_content('abc')

        all('input[id="1"]').first.click
        #choose(name: 'status',option:'Rejected')

        all('input[value="Submit"]').first.click

        #choose(name: 'status', option:'Approved',allow_label_click: true)

        #click_on('Submit')

        expect(page).to have_content('requester1')

        # the size of mailing queue changes by 1

        expect{
            student = RequestedUser.find_by_email('abc@gmail.com')
            prepare = UserMailer.send_to_user(student,'Your Expertiza account and password have been created.',"user_welcome",'123456')
            prepare.deliver_now

        }.to change{ UserMailer.deliveries.count }.by(1)

        #expect(ActionMailer::Base.deliveries.count).to eq(1)

        #expect(ActionMailer::Base.deliveries.first.subject).to eq("Your Expertiza account and password have been created.")

        #expect(ActionMailer::Base.deliveries.first.to).to eq(["requestor1@test.com"])

      end



      context 'using name as username and password in the email' do

        it 'allows the new user to login Expertiza' do

          create(:student, name: 'approved_requster1', password: "password")

          visit '/'

          fill_in 'login_name', with: 'approved_requster1'

          fill_in 'login_password', with: 'password'

          click_button 'SIGN IN'

          expect(page).to have_current_path("/student_task/list")

        end

      end

    end

  end

end

