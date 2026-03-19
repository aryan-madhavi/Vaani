  gcloud iam service-accounts create vaani-backend \
    --display-name="Vaani Backend" \
    --project=autocalltranslate

  gcloud projects add-iam-policy-binding autocalltranslate \
    --member="serviceAccount:vaani-backend@autocalltranslate.iam.gserviceaccount.com" \
    --role="roles/speech.client"

  gcloud projects add-iam-policy-binding autocalltranslate \
    --member="serviceAccount:vaani-backend@autocalltranslate.iam.gserviceaccount.com" \
    --role="roles/cloudtranslate.user"

  gcloud projects add-iam-policy-binding autocalltranslate \
    --member="serviceAccount:vaani-backend@autocalltranslate.iam.gserviceaccount.com" \
    --role="roles/cloudtexttospeech.user"

  gcloud iam service-accounts keys create backend/secrets/serviceAccountKey.json \
    --iam-account=vaani-backend@autocalltranslate.iam.gserviceaccount.com