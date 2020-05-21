FROM amazonlinux

ARG MAGENTO_VERSION=2.3.4

ENV MAGEUSER=MAG005397149
ENV MAGEPASS=2f7e27231024a6cbc3e075f5a74b8264e6badb56

ENV MAGENTO_INSTALLER_DIR=/opt

RUN cd "${MAGENTO_INSTALLER_DIR}" && \
  curl -O "https://${MAGEUSER}:${MAGEPASS}@www.magentocommerce.com/products/downloads/file/Magento-CE-${MAGENTO_VERSION}_sample_data.zip"

REM The idea would be to only download from magento if it doesn't exist in S3, and put it there when we're done
REM We could do that with a simple script.  I guess we'd want to do something similar with the database backup